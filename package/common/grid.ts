import { Vector2 } from "./vector";

interface GridEntryOptions {
    coords: Vector2;
    width?: number;
    height?: number;
    radius?: number;
}

const validateEntry = Symbol('validateEntry');
const refreshEntry = Symbol('refreshEntry');

interface EntryGrid {
    /** Checks whether an entry can be indexed by this grid. */
    [validateEntry](entry: GridEntryOptions): void;
    /** Reindexes an entry after its bounds change. */
    [refreshEntry](entry: GridEntry): void;
}

const entryGrids = new WeakMap<GridEntry, Set<EntryGrid>>();

/**
 * Base class for grid entries. Property setters automatically update all grids
 * containing the entry.
 */
export class GridEntry {
    #state: GridEntryOptions = { coords: new Vector2(0, 0) };

    /** Creates an entry from a centre position and optional dimensions or radius. */
    constructor(options: GridEntryOptions) {
        this.set(options);
    }

    /** Returns the horizontal centre coordinate. */
    public get x() {
        return this.#state.coords.x;
    }

    /** Returns the vertical centre coordinate. */
    public get y() {
        return this.#state.coords.y;
    }

    /** Returns a copy of the centre position. */
    public get coords() {
        return this.#state.coords.clone();
    }

    /** Moves the entry and updates every grid containing it. */
    public set coords(coords: Vector2) {
        this.set({ coords });
    }

    /** Returns the horizontal extent, or undefined to use each grid's cell width. */
    public get width() {
        return this.#state.width;
    }

    /** Changes the horizontal extent and switches from radius to rectangular dimensions. */
    public set width(value: number | undefined) {
        this.set({ width: value });
    }

    /** Returns the vertical extent, or undefined to use each grid's cell height. */
    public get height() {
        return this.#state.height;
    }

    /** Changes the vertical extent and switches from radius to rectangular dimensions. */
    public set height(value: number | undefined) {
        this.set({ height: value });
    }

    /** Returns the configured radius, if the entry uses radius-based dimensions. */
    public get radius() {
        return this.#state.radius;
    }

    /** Sets both extents to twice the radius, or zero when undefined, and updates subscribed grids. */
    public set radius(value: number | undefined) {
        this.set({ radius: value });
    }

    /** Validates an update against subscribed grids, then applies and reindexes it. */
    public set(options: Partial<GridEntryOptions>): this {
        const hasRadius = 'radius' in options;

        if (hasRadius && ('width' in options || 'height' in options))
            throw new TypeError('Use either radius or width/height in an update.');

        const next = { ...this.#state, ...options };

        if (hasRadius) {
            next.width = next.height = options.radius ? options.radius * 2 : 0;
        } else if ('width' in options || 'height' in options) {
            delete next.radius;
        }


        const grids = [...(entryGrids.get(this) ?? [])];

        for (const grid of grids) grid[validateEntry](next);

        this.#state = next;

        for (const grid of grids) grid[refreshEntry](this);

        return this;
    }
}

type GridEntryInput<T extends GridEntry> = T | (GridEntry extends T ? GridEntryOptions : never);

interface GridCache<T extends GridEntry> {
    left?: number;
    right?: number;
    top?: number;
    bottom?: number;
    lastX?: number;
    lastY?: number;
    entries: Set<T>;
    lastCell: Set<T>;
}

/** Copies the values accepted by the predicate into a new set. */
function filterSet<T>(set: Set<T>, predicate: (value: T) => boolean) {
    const result = new Set<T>();

    for (const value of set) {
        if (predicate(value)) result.add(value);
    }

    return result;
}

/**
 * A 2D spatial grid for efficiently indexing and querying objects in a space.
 */
export class Grid<T extends GridEntry = GridEntry> {
    #rows = new Map<number, Map<number, Set<T>>>();
    #cache = {} as GridCache<T>;
    #dimensions = new WeakMap<T, [number, number, number, number]>();
    #entries = new Set<T>();

    /** All registered entries. Use add/remove to change membership. */
    public get entries(): ReadonlySet<T> {
        return this.#entries;
    }

    /** Creates a grid with positive finite cell dimensions, defaulting to square cells. */
    constructor(readonly cellWidth: number = 128, readonly cellHeight = cellWidth) {
        if (!Number.isFinite(cellWidth) || cellWidth <= 0 || !Number.isFinite(cellHeight) || cellHeight <= 0)
            throw new RangeError('Grid cell dimensions must be positive finite numbers.');

        this.resetCache();
    }

    /**
     * Calculates the grid cell boundaries occupied by a rectangle.
     *
     * @param wx The x-coordinate to convert to grid space.
     * @param wy The y-coordinate to convert to grid space.
     * @param width The width of the rectangle (optional, defaults to cellWidth).
     * @param height The height of the rectangle (optional, defaults to cellHeight).
     * @returns A tuple representing grid cell indices.
     */
    private getDimensions(
        wx: number,
        wy: number,
        width = this.cellWidth,
        height = this.cellHeight,
    ): [number, number, number, number] {
        if (![wx, wy, width, height].every(Number.isFinite) || width < 0 || height < 0)
            throw new RangeError('Grid coordinates must be finite and extents nonnegative.');

        const halfWidth = width / 2;
        const halfHeight = height / 2;

        const left = Math.floor((wx - halfWidth) / this.cellWidth);
        const right = Math.floor((wx + halfWidth) / this.cellWidth);
        const top = Math.floor((wy - halfHeight) / this.cellHeight);
        const bottom = Math.floor((wy + halfHeight) / this.cellHeight);

        if (![left, right, top, bottom].every(Number.isSafeInteger))
            throw new RangeError('Grid cell indices must be safe integers.');

        return [left, right, top, bottom];
    }

    /**
     * Clears the internal cache used to optimise repeated queries.
     */
    private resetCache() {
        this.#cache = {
            entries: new Set<T>(),
            lastCell: new Set<T>(),
        };
    }

    /**
     * Converts world space coordinates to grid-space indices.
     *
     * @param wx The `x` position in world space.
     * @param wy The `y` position in world space.
     * @returns A tuple representing the grid cell indices.
     */
    public getGridPosition(wx: number, wy: number): [number, number] {
        const x = Math.floor(wx / this.cellWidth);
        const y = Math.floor(wy / this.cellHeight);

        return [x, y];
    }

    /**
     * Converts grid-space indices to world space coordinates.
     * @param gx The horizontal grid-space index (column).
     * @param gy The vertical grid-space index (row).
     * @returns A tuple representing the centre of the grid cell in world space.
     */
    public getWorldPosition(gx: number, gy: number): [number, number] {
        const wx = gx * this.cellWidth + 0.5 * this.cellWidth;
        const wy = gy * this.cellHeight + 0.5 * this.cellHeight;

        return [wx, wy];
    }

    /**
     * Retrieves the set of entries in the cell containing the specified world coordinates.
     * @param wx The `x` position in world space.
     * @param wy The `y` position in world space.
     * @returns A read-only set of entries in the cell.
     */
    public getCell(wx: number, wy: number): ReadonlySet<T> {
        const [gx, gy] = this.getGridPosition(wx, wy);

        if (this.#cache.lastX !== gx || this.#cache.lastY !== gy) {
            this.#cache.lastX = gx;
            this.#cache.lastY = gy;
            this.#cache.lastCell = this.#rows.get(gy)?.get(gx) || new Set();
        }

        const cell = this.#cache.lastCell;

        return cell;
    }

    /**
     * Retrieves entries in cells touched by a cell-sized rectangle centred on a point.
     * @param wx The `x` position in world space.
     * @param wy The `y` position in world space.
     * @param predicate An optional filter applied to the entries.
     * @returns A read-only set of matching entries.
     */
    public getEntries(wx: number, wy: number, predicate?: (entry: T) => boolean): ReadonlySet<T> {
        const [left, right, top, bottom] = this.getDimensions(wx, wy);

        if (
            this.#cache.left === left &&
            this.#cache.right === right &&
            this.#cache.top === top &&
            this.#cache.bottom === bottom
        ) {
            return predicate ? filterSet(this.#cache.entries, predicate) : this.#cache.entries;
        }

        const entries = new Set<T>();

        for (let y = top; y <= bottom; y++) {
            const row = this.#rows.get(y);

            if (!row) continue;

            for (let x = left; x <= right; x++) {
                const cell = row.get(x);

                if (!cell) continue;

                for (const entry of cell) {
                    entries.add(entry);
                }
            }
        }

        this.#cache.left = left;
        this.#cache.right = right;
        this.#cache.top = top;
        this.#cache.bottom = bottom;
        this.#cache.entries = entries;

        return predicate ? filterSet(this.#cache.entries, predicate) : this.#cache.entries;
    }

    /**
     * Adds an entry, wrapping plain options in a new GridEntry.
     * @returns The registered instance. Use it for updates and removal; the input
     * options object is copied and is not tracked. Subclass grids require instances.
     */
    public add(input: GridEntryInput<T>): T {
        const entry = (input instanceof GridEntry ? input : new GridEntry(input)) as T;
        if (this.entries.has(entry)) {
            throw new Error(`Entry already exists in the grid.`);
        }

        const [left, right, top, bottom] = this.getDimensions(entry.x, entry.y, entry.width, entry.height);

        this.addToCells(entry, [left, right, top, bottom]);

        this.#dimensions.set(entry, [left, right, top, bottom]);
        this.resetCache();
        this.#entries.add(entry);
        let grids = entryGrids.get(entry);
        if (!grids) entryGrids.set(entry, (grids = new Set()));
        grids.add(this);
        return entry;
    }

    /**
     * Removes an entry from the grid.
     * @param entry An existing grid entry.
     */
    public remove(entry: T) {
        if (!this.entries.has(entry)) return false;

        const [left, right, top, bottom] = this.#dimensions.get(entry)!;

        const success = this.removeFromCells(entry, [left, right, top, bottom]);

        if (success) {
            this.resetCache();
            this.#entries.delete(entry);
            this.#dimensions.delete(entry);
            entryGrids.get(entry)?.delete(this);
        }

        return success;
    }

    /** Registers an entry in every cell within the inclusive index bounds. */
    private addToCells(entry: T, [left, right, top, bottom]: [number, number, number, number]) {
        for (let y = top; y <= bottom; y++) {
            let row = this.#rows.get(y);

            if (!row) {
                this.#rows.set(y, (row = new Map()));
            }

            for (let x = left; x <= right; x++) {
                if (!row.has(x)) row.set(x, new Set());

                row.get(x)!.add(entry);
            }
        }
    }

    /** Removes an entry from the indexed cells and prunes empty rows and cells. */
    private removeFromCells(entry: T, [left, right, top, bottom]: [number, number, number, number]) {
        let success = false;

        for (let y = top; y <= bottom; y++) {
            const row = this.#rows.get(y);

            if (!row) continue;

            for (let x = left; x <= right; x++) {
                const cell = row.get(x);

                if (!cell) continue;

                if (cell.delete(entry)) success = true;

                if (cell.size === 0) row.delete(x);
            }

            if (row.size === 0) this.#rows.delete(y);
        }
        return success;
    }

    /**
     * Adds multiple entries, wrapping plain options, and returns the registered instances.
     */
    public addAll(entries: readonly GridEntryInput<T>[]): T[] {
        return entries.map((entry) => this.add(entry));
    }

    /**
     * Removes multiple entries from the grid.
     * @param entries An array of entries to remove.
     */
    public removeAll(entries: T[]) {
        for (const entry of entries) this.remove(entry);
    }

    /**
     * Updates the position and dimensions of an existing entry in the grid.
     * @param entry The entry to update.
     */
    public update(entry: T, options: Partial<GridEntryOptions>) {
        if (!this.entries.has(entry)) throw new Error("Cannot update an entry that doesn't exist in the grid.");

        entry.set(options);
    }

    /** @internal Validates an entry update before any subscribed grid is changed. */
    public [validateEntry](entry: GridEntryOptions) {
        this.getDimensions(entry.coords.x, entry.coords.y, entry.width, entry.height);
    }

    /** @internal Reindexes without changing registration or subscription order. */
    public [refreshEntry](entry: T) {
        const previous = this.#dimensions.get(entry)!;
        const next = this.getDimensions(entry.x, entry.y, entry.width, entry.height);
        if (next.every((value, index) => value === previous[index])) return;

        this.removeFromCells(entry, previous);
        this.addToCells(entry, next);
        this.#dimensions.set(entry, next);
        this.resetCache();
    }

    /**
     * Removes all entries from the grid.
     */
    public clear() {
        for (const entry of this.entries) entryGrids.get(entry)?.delete(this);
        this.#rows.clear();
        this.#dimensions = new WeakMap();
        this.#entries.clear();
        this.resetCache();
    }
}

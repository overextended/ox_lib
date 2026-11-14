type MsgpackBuffer = { buffer: any; type: number };

import { clamp } from './math';

const EXT_VECTOR2 = 20;
const EXT_VECTOR3 = 21;
const EXT_VECTOR4 = 22;

/**
 * An object with vector components.
 */
export interface Vec {
    x: number;
    y: number;
    z?: number;
    w?: number;
}

/**
 * Represents a 2-dimensional vector.
 */
export interface Vec2 {
    x: number;
    y: number;
    z?: undefined;
    w?: undefined;
}

/**
 * Represents a 3-dimensional vector.
 */
export interface Vec3 {
    x: number;
    y: number;
    z: number;
    w?: undefined;
}

/**
 * Represents a 4-dimensional vector.
 */
export interface Vec4 {
    x: number;
    y: number;
    z: number;
    w: number;
}

/**
 * An array that can be converted to a vector.
 */
type VectorArray<T> = T extends typeof Vector
    ? VectorArray<InstanceType<T>>
    : T extends Vec4
    ? [number, number, number, number]
    : T extends Vec3
    ? [number, number, number]
    : T extends Vec2
    ? [number, number]
    : any;

/**
 * An object that can be converted to a vector.
 */
type VectorObject<T> = T extends typeof Vector
    ? VectorObject<InstanceType<T>>
    : T extends Vec4
    ? Vec4
    : T extends Vec3
    ? Vec3
    : T extends Vec2
    ? Vec2
    : Vec;

type CVector = typeof Vector2 | typeof Vector3 | typeof Vector4;
type VectorKey = 'x' | 'y' | 'z' | 'w';
type VectorSwizzle = Vec2Swizzle | Vec3Swizzle | Vec4Swizzle;
type Vec2Swizzle = `${VectorKey}${VectorKey}`;
type Vec3Swizzle = `${VectorKey}${VectorKey}${VectorKey}`;
type Vec4Swizzle = `${VectorKey}${VectorKey}${VectorKey}${VectorKey}`;

/**
 * A base vector class inherited by all vector classes.
 */
export abstract class Vector {
    static size: number;
    static keys: readonly (keyof Vec)[];
    declare x: number;
    declare y: number;
    declare z?: number;
    declare w?: number;

    /**
     * Validates the component types supplied by a concrete vector constructor.
     *
     * @param x - The x-component of the vector.
     * @param y - The y-component of the vector.
     * @param z - The z-component of the vector (optional).
     * @param w - The w-component of the vector (optional).
     */
    constructor(...args: number[]) {
        for (let i = 0; i < this.size; i++) {
            if (typeof args[i] !== 'number') {
                throw new TypeError(
                    `${this.constructor.name
                    } argument at index ${i} must be a number, but got ${typeof args[i]}`,
                );
            }
        }
    }

    /** Returns the number of components in this vector class. */
    public get size() {
        return (this.constructor as CVector).size;
    }


    /**
     * Creates a vector from binary data in a MsgpackBuffer.
     * @param msgpackBuffer The buffer containing binary data.
     * @returns A new vector instance.
     */
    private static fromBuffer<T extends CVector>(this: T, { buffer, type }: MsgpackBuffer) {
        if (type < EXT_VECTOR2 || type > EXT_VECTOR4)
            throw new Error("Buffer type is not a valid Vector.");

        const length = buffer.length / 4;
        const arr = new Float32Array(buffer.buffer, buffer.byteOffset, length) as VectorArray<T>;

        return this.fromArray(arr)
    }

    /**
     * Creates a vector from an array of numbers.
     *
     * @param primitive - An array representing the components of a vector.
     * @returns A new instance of the receiving vector class.
     */
    public static fromArray<T extends CVector, U extends VectorArray<T>>(
        this: T,
        primitive: U,
    ): InstanceType<T> {
        const [x, y, z, w] = primitive as [number, number, number?, number?];
        return new this(x, y, z, w) as InstanceType<T>;
    }

    /**
     * Creates a vector from a string, number, array, or object.
     *
     * @param primitive - A string, number, array, or object with vector-like components.
     * @returns A new vector instance corresponding to the input.
     */
    public static fromInput<
        T extends CVector,
        U extends VectorObject<T> | VectorArray<T> | MsgpackBuffer,
    >(this: T, primitive: string | number | U): InstanceType<T> {
        switch (typeof primitive) {
            case 'string':
                const matches = (primitive as string).match(/(?<![a-zA-Z0-9_])-?\d+(?:\.\d+)?/g);

                if (!matches || matches.length > 4) break;

                return this.fromArray(matches.map(Number) as VectorArray<T>)
            case 'number':
                return new this(
                    primitive,
                    primitive,
                    primitive,
                    primitive,
                ) as InstanceType<T>;
            case 'object':
                if (Array.isArray(primitive))
                    return this.fromArray(primitive as VectorArray<T>);

                if ("buffer" in primitive) return this.fromBuffer(primitive as MsgpackBuffer);

                const { x, y, z, w } = primitive as Vec;

                return new this(x, y, z, w) as InstanceType<T>;
        }

        throw new Error(`Could not parse value into vector components (received ${JSON.stringify(primitive)}).`)
    }

    /**
     * Converts a list of component arrays into an array of vector instances.
     *
     * @param primitives - An array of number arrays representing multiple vectors.
     * @returns An array of vector instances.
     */
    public static fromArrays<T extends typeof Vector, U extends VectorArray<T>[]>(
        this: T,
        primitives: U,
    ): InstanceType<T>[] {
        return primitives.map(this.fromArray, this) as InstanceType<T>[];
    }

    /**
     * Applies a mathematical operation to each component of the vector.
     *
     * @param v The other vector or scalar to operate with.
     * @param operator - A function that defines the operation to apply.
     * @returns A reference to the vector.
     */
    private operate(
        v: Partial<VectorObject<this> | this> | number,
        operator: (x: number, y: number) => number,
    ): this {
        const vec =
            this.constructor === v.constructor
                ? v
                : (this.constructor as any).fromInput(v);

        this.x = operator(this.x, vec.x);
        this.y = operator(this.y, vec.y);

        if (this.size > 2) this.z = operator(this.z!, vec.z);
        if (this.size > 3) this.w = operator(this.w!, vec.w);

        return this;
    }

    /**
     * Adds the components of the vector by the components of another vector or scalar value.
     * @param v The target vector or scalar value.
     * @returns A reference to the vector.
     */
    public add(v: VectorObject<this> | number): this {
        return this.operate(v, (x, y) => x + y);
    }

    /**
     * Subtracts the components of the vector by the components of another vector or scalar value.
     * @param v The target vector or scalar value.
     * @returns A reference to the vector.
     */
    public subtract(v: VectorObject<this> | number): this {
        return this.operate(v, (x, y) => x - y);
    }

    /**
     * Multiplies the components of the vector by the components of another vector or scalar value.
     * @param v The target vector or scalar value.
     * @returns A reference to the vector.
     */
    public multiply(v: VectorObject<this> | number): this {
        return this.operate(v, (x, y) => x * y);
    }

    /**
     * Divides the components of the vector by the components of another vector or scalar value.
     * @param v The target vector or scalar vector.
     * @returns A reference to the vector.
     */
    public divide(v: VectorObject<this> | number): this {
        return this.operate(v, (x, y) => x / y);
    }

    /**
     * Linearly interpolates each component of the vector towards another vector or scalar value.
     * @param v The target vector or scalar value.
     * @param factor The interpolation factor, typically between 0 and 1.
     * @returns A reference to the vector.
     */
    public lerp(v: VectorObject<this> | number, factor: number): this {
        return this.operate(v, (a, b) => a + (b - a) * factor);
    }

    /**
     * Computes the dot product of this vector and another.
     *
     * @param v The vector to perform the dot product with.
     * @returns The scalar dot product value.
     */
    public dot(v: VectorObject<this>): number {
        const vec =
            v instanceof Vector ? v : (this.constructor as any).fromInput(v);

        if (this.size !== vec.size)
            throw new Error('Vectors must have the same dimensions.');

        return (
            this.x * vec.x +
            this.y * vec.y +
            (this.size > 2 ? this.z! * vec.z! : 0) +
            (this.size > 3 ? this.w! * vec.w! : 0)
        );
    }

    /**
     * Returns a normalized copy of this vector with magnitude 1.
     *
     * @returns A normalized vector.
     */
    public normalize(): this {
        return this.clone().divide(this.length());
    }

    /**
     * Calculates the squared Euclidean length (magnitude) of this vector.
     *
     * @returns The magnitude of the vector.
     */
    public lengthSquared(): number {
        return (
            this.x * this.x +
            this.y * this.y +
            (this.size > 2 ? this.z! * this.z! : 0) +
            (this.size > 3 ? this.w! * this.w! : 0)
        );
    }

    /**
     * Calculates the Euclidean length (magnitude) of this vector.
     *
     * @returns The magnitude of the vector.
     */
    public length(): number {
        return Math.hypot(this.x, this.y, this.z ?? 0, this.w ?? 0);
    }

    /** Visits each component in x, y, z, w order with its key and index. */
    public forEach(
        callback: (value: number, key: keyof Vec, index: number) => void,
    ): void {
        const keys = (this.constructor as typeof Vector).keys;

        for (let i = 0; i < keys.length; i++) {
            const key = keys[i] as keyof Vec;
            callback(this[key]!, key, i);
        }
    }

    /** Iterates over component values in x, y, z, w order. */
    public abstract [Symbol.iterator](): IterableIterator<number>;

    /**
     * Returns a string representation of the vector, such as "vector3(1, 2, 3)".
     */
    public toString() {
        return `vector${this.size}(${this.toArray().join(', ')})`;
    }

    /**
     * Creates a new vector with the same component values as this one.
     *
     * @returns A cloned vector.
     */
    public clone(): this {
        return (this.constructor as any).fromInput(this) as this;
    }

    /**
     * Computes the squared Euclidean distance to another vector.
     *
     * @param v The vector to compute distance to.
     * @returns The squared distance.
     */
    public distanceSquared(v: VectorObject<this>): number {
        const vec =
            v instanceof Vector ? v : (this.constructor as any).fromInput(v);

        return (
            (this.x - vec.x) ** 2 +
            (this.y - vec.y) ** 2 +
            (this.size > 2 ? (this.z! - vec.z!) ** 2 : 0) +
            (this.size > 3 ? (this.w! - vec.w!) ** 2 : 0)
        );
    }

    /**
     * Computes the Euclidean distance to another vector.
     *
     * @param v The vector to compute distance to.
     * @returns The distance.
     */
    public distance(v: VectorObject<this>): number {
        return Math.hypot(
            this.x - v.x,
            this.y - v.y,
            this.size > 2 ? this.z! - v.z! : 0,
            this.size > 3 ? this.w! - v.w! : 0,
        );
    }

    /**
     * Converts the vector to an array of component values.
     *
     * @returns An array representing the vector.
     */
    public toArray() {
        return [...this];
    }

    /**
     * Replaces the current vector's components with another vector's values.
     *
     * @param v The vector to copy components from.
     * @returns A reference to the vector.
     */
    public copy(v: Partial<VectorObject<this>>): this {
        return this.operate(v, (_, y) => y);
    }

    /**
     * Creates a new vector by reordering or duplicating components using a swizzle string.
     *
     * @param components - A string like 'xy', 'zyx', or 'wzyx' specifying the desired component order.
     * @returns A new vector based on the swizzle pattern.
     */
    public swizzle<T extends VectorSwizzle>(
        components: T,
    ): T extends Vec2Swizzle
        ? Vector2
        : T extends Vec3Swizzle
        ? Vector3
        : Vector4 {
        if (!/^[xyzw]+$/.test(components))
            throw new Error(`Invalid key in swizzle components (${components}).`);

        const arr = components.split('').map((char) => (this as any)[char] ?? 0);
        const vector = arr.length === 2 ? Vector2 : arr.length === 3 ? Vector3 : arr.length === 4 ? Vector4 : null;

        if (!vector) throw new Error(`Invalid vector length (received ${arr.length} components)`);

        return vector.fromArray(arr) as any;
    }

    /**
     * Compares this vector to another for exact component equality.
     *
     * @param v The vector to compare with.
     * @returns `true` if all components are equal, otherwise `false`.
     */
    public equals(v: this) {
        if (this.size !== v.size) return false;

        const keys = (this.constructor as typeof Vector).keys;

        for (const key of keys) if (this[key] !== v[key]) return false;

        return true;
    }

    /**
     * Clamps a vector's components between the corresponding components of `min` and `max`.
     * @param min A scalar or vector defining the minimum value for each component.
     * @param max A scalar or vector defining the maximum value for each component.
     * @returns A reference to the vector.
     */
    public clamp(
        min: VectorObject<this> | number,
        max: VectorObject<this> | number,
    ): this {
        const minVec =
            typeof min === 'number' || min instanceof Vector
                ? min
                : (this.constructor as any).fromInput(min);

        const maxVec =
            typeof max === 'number' || max instanceof Vector
                ? max
                : (this.constructor as any).fromInput(max);

        const minIsNumber = typeof min === 'number';
        const maxIsNumber = typeof max === 'number';

        this.forEach((value, key) => {
            const minValue = minIsNumber ? min : minVec[key];
            const maxValue = maxIsNumber ? max : maxVec[key];

            this[key] = clamp(value, minValue, maxValue);
        });

        return this;
    }

    /**
     * Rounds the components of the vector up to the nearest integer.
     * @returns A reference to the vector.
     */
    public ceil() {
        return this.operate(this, (x) => Math.ceil(x));
    }

    /**
     * Rounds the components of the vector down to the nearest integer.
     * @returns A reference to the vector.
     */
    public floor() {
        return this.operate(this, (x) => Math.floor(x));
    }

    /**
     * Rounds the components of the vector to the nearest integer.
     * @returns A reference to the vector.
     */
    public round() {
        return this.operate(this, (x) => Math.round(x));
    }
}

/**
 * Represents a 2-dimensional vector.
 */
export class Vector2 extends Vector {
    static override size = 2;
    static override keys: readonly (keyof Vec2)[] = ['x', 'y'];

    /**
     * Constructs a new 2D vector.
     * @param x The x-component of the vector.
     * @param y The y-component of the vector.
     */
    constructor(x = 0, y = 0) {
        super(x, y);

        this.x = x;
        this.y = y;
    }

    /** Iterates over this vector's components in declaration order. */
    *[Symbol.iterator]() {
        yield this.x;
        yield this.y;
    }

    /**
     * Computes the cross product between this and another vector.
     *
     * @param v The other vector.
     * @returns The signed scalar cross product.
     */
    public cross(v: VectorObject<this>): number {
        const vec = v instanceof Vector ? v : Vector2.fromInput(v);

        return this.x * vec.y - this.y * vec.x;
    }
}

/**
 * Represents a 3-dimensional vector.
 */
export class Vector3 extends Vector {
    static override size = 3;
    static override keys: readonly (keyof Vec3)[] = ['x', 'y', 'z'];
    public override z = 0;

    /**
     * Constructs a new 3D vector.
     * @param x The x-component of the vector.
     * @param y The y-component of the vector.
     * @param z The z-component of the vector.
     */
    constructor(x = 0, y = 0, z = 0) {
        super(x, y, z);

        this.x = x;
        this.y = y;
        this.z = z;
    }

    /** Iterates over this vector's components in declaration order. */
    *[Symbol.iterator]() {
        yield this.x;
        yield this.y;
        yield this.z;
    }

    /**
     * Computes the cross product between this and another vector.
     *
     * @param v The other vector.
     * @returns A new vector orthogonal to both inputs.
     */
    public cross(v: VectorObject<this>): Vector3 {
        const vec = v instanceof Vector3 ? v : Vector3.fromInput(v);

        return new Vector3(
            this.y * vec.z - this.z * vec.y,
            this.z * vec.x - this.x * vec.z,
            this.x * vec.y - this.y * vec.x,
        );
    }
}

/**
 * Represents a 4-dimensional vector.
 */
export class Vector4 extends Vector {
    static override size = 4;
    static override keys: readonly (keyof Vec4)[] = ['x', 'y', 'z', 'w'];
    public override z = 0;
    public override w = 0;

    /**
     * Constructs a new 4D vector.
     * @param x The x-component of the vector.
     * @param y The y-component of the vector.
     * @param z The z-component of the vector.
     * @param w The w-component of the vector.
     */
    constructor(x = 0, y = 0, z = 0, w = 0) {
        super(x, y, z, w);

        this.x = x;
        this.y = y;
        this.z = z;
        this.w = w;
    }

    /** Iterates over this vector's components in declaration order. */
    *[Symbol.iterator]() {
        yield this.x;
        yield this.y;
        yield this.z;
        yield this.w;
    }
}

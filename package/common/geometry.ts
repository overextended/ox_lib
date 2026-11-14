import { clamp } from './math';
import { type Vector, Vector2, Vector3 } from './vector';

export interface Point2D {
  x: number;
  y: number;
}

export interface Point3D extends Point2D {
  z: number;
}

export interface Bounds2D {
  minX: number;
  maxX: number;
  minY: number;
  maxY: number;
}

export interface Bounds3D extends Bounds2D {
  minZ: number;
  maxZ: number;
}

export interface Shape2D {
  area: number;
  centroid: Readonly<Vector2>;
  bounds: Bounds2D;
}

export interface Shape3D {
  volume: number;
  centroid: Readonly<Vector3>;
  bounds: Bounds3D;
}

/**
 * Represents a 2D circle.
 */
export class Circle implements Shape2D {
  readonly coords: Readonly<Vector2>;
  readonly radius: number;
  readonly area: number;
  #bounds?: Readonly<Bounds2D>;

  /**
   * Creates a new circle.
   * @param coords The centre of the circle.
   * @param radius The radius of the circle.
   */
  constructor(coords: Vector2, radius: number) {
    if (!Number.isFinite(radius) || radius <= 0) throw new RangeError('Radius must be positive and finite.');

    if (!coords.toArray().every(Number.isFinite)) throw new RangeError('Shape coordinates must be finite.');

    this.coords = Object.freeze(coords.clone());
    this.radius = radius;
    this.area = Math.PI * this.radius ** 2;
  }

  /**
   * Calculates the axis-aligned bounding box of the circle.
   */
  public calculateBounds() {
    const { x, y } = this.coords;
    const r = this.radius;

    return { minX: x - r, minY: y - r, maxX: x + r, maxY: y + r };
  }

  /**
   * Checks if a point (x, y) lies within the circle.
   * @param x The x coordinate of the point.
   * @param y The y coordinate of the point.
   */
  public contains(x: number, y: number) {
    const dx = x - this.coords.x;
    const dy = y - this.coords.y;

    return dx * dx + dy * dy <= this.radius ** 2;
  }

  /**
   * The axis-aligned bounding box of the circle.
   */
  public get bounds() {
    return (this.#bounds ??= Object.freeze(this.calculateBounds()));
  }

  /**
   * The geometric centre of the circle.
   */
  public get centroid() {
    return this.coords;
  }

  /**
   * Returns a deep clone of the circle.
   */
  public clone() {
    return new Circle(new Vector2(this.coords.x, this.coords.y), this.radius);
  }

  /**
   * Returns the closest point on the circle's circumference to a given point.
   * @param point The point to project onto the circle.
   */
  public closestPoint(point: Vector2) {
    const direction = point.clone().subtract(this.coords);
    const distance = direction.length();

    if (distance === 0) {
      direction.x = this.coords.x + this.radius;
      direction.y = this.coords.y;

      return direction;
    }

    direction.multiply(this.radius / distance);

    return direction.add(this.coords);
  }
}

/**
 * Represents a 3D cylinder formed by extruding a circle along the Z axis.
 */
export class Cylinder implements Shape3D {
  readonly circle: Circle;
  readonly z: number;
  readonly height: number;
  #bounds?: Readonly<Bounds3D>;
  #centroid?: Readonly<Vector3>;

  /**
   * Creates a new cylinder.
   * @param coords The centre position of the cylinder.
   * @param radius The radius of the cylinder.
   * @param height The height of the cylinder.
   * @param z The centre Z position of the cylinder.
   */
  constructor(coords: Vector2, radius: number, height: number, z: number) {
    if (!Number.isFinite(height) || height <= 0 || !Number.isFinite(z))
      throw new RangeError('Height must be positive and finite, and Z must be finite.');

    this.circle = new Circle(coords, radius);
    this.z = z;
    this.height = height;
  }

  /**
   * Calculates the axis-aligned bounding box of the cylinder.
   */
  public calculateBounds() {
    const bounds = this.circle.calculateBounds() as Bounds3D;
    const half = this.height / 2;
    bounds.minZ = this.z - half;
    bounds.maxZ = this.z + half;

    return bounds;
  }

  /**
   * Calculates the geometric centre of the cylinder.
   */
  public calculateCentroid() {
    const { x, y } = this.circle.centroid;
    return new Vector3(x, y, this.z);
  }

  /**
   * The volume of the cylinder.
   */
  public get volume() {
    return this.circle.area * this.height;
  }

  /**
   * The axis-aligned bounding box of the cylinder.
   */
  public get bounds() {
    return (this.#bounds ??= Object.freeze(this.calculateBounds()));
  }

  /**
   * The geometric centre of the cylinder.
   */
  public get centroid() {
    return (this.#centroid ??= Object.freeze(this.calculateCentroid()));
  }

  /**
   * Checks if a point (x, y, z) lies within the cylinder.
   * @param x The x coordinate of the point.
   * @param y The y coordinate of the point.
   * @param z The z coordinate of the point.
   */
  public contains(x: number, y: number, z?: number) {
    const half = this.height / 2;

    if (z !== undefined && (z < this.z - half || z > this.z + half)) return false;

    return this.circle.contains(x, y);
  }

  /**
   * Returns a deep clone of the cylinder.
   */
  public clone() {
    return new Cylinder(
      new Vector2(this.circle.coords.x, this.circle.coords.y),
      this.circle.radius,
      this.height,
      this.z,
    );
  }

  /**
   * Returns the closest point on the cylinder's surface to a given point.
   * @param point The point to project onto the cylinder.
   */
  public closestPoint(point: Vector3) {
    const direction = new Vector2(point.x, point.y).subtract(this.circle.coords);

    const distance = direction.length();

    if (distance === 0) {
      direction.x = this.circle.coords.x + this.circle.radius;
      direction.y = this.circle.coords.y;
    } else {
      direction.multiply(this.circle.radius / distance);
      direction.add(this.circle.coords);
    }

    const half = this.height / 2;
    const z = clamp(point.z, this.z - half, this.z + half);

    const side = new Vector3(direction.x, direction.y, z);
    const capZ = point.z < this.z ? this.z - half : this.z + half;
    const cap =
      distance <= this.circle.radius
        ? new Vector3(point.x, point.y, capZ)
        : new Vector3(direction.x, direction.y, capZ);

    return point.distance(cap) < point.distance(side) ? cap : side;
  }
}

/**
 * Represents a 3D sphere.
 */
export class Sphere implements Shape3D {
  readonly coords: Readonly<Vector3>;
  readonly radius: number;
  #bounds?: Readonly<Bounds3D>;

  /**
   * Creates a new sphere.
   * @param coords The centre of the sphere.
   * @param radius The radius of the sphere.
   */
  constructor(coords: Vector3, radius: number) {
    if (!Number.isFinite(radius) || radius <= 0) throw new RangeError('Radius must be positive and finite.');

    if (!coords.toArray().every(Number.isFinite)) throw new RangeError('Shape coordinates must be finite.');

    this.coords = Object.freeze(coords.clone());
    this.radius = radius;
  }

  /**
   * Calculates the axis-aligned bounding box of the sphere.
   */
  public calculateBounds() {
    const { x, y, z } = this.coords;
    const r = this.radius;

    return {
      minX: x - r,
      minY: y - r,
      minZ: z - r,
      maxX: x + r,
      maxY: y + r,
      maxZ: z + r,
    };
  }

  /**
   * Checks if a point (x, y, z) lies within the sphere.
   * @param x The x coordinate of the point.
   * @param y The y coordinate of the point.
   * @param z The z coordinate of the point.
   */
  public contains(x: number, y: number, z: number) {
    const dx = x - this.coords.x;
    const dy = y - this.coords.y;
    const dz = z - this.coords.z;

    return dx * dx + dy * dy + dz * dz <= this.radius ** 2;
  }

  /**
   * Calculates the geometric centre of the sphere.
   */
  public calculateCentroid() {
    return this.coords;
  }

  /**
   * The volume of the sphere.
   */
  public get volume() {
    return (4 / 3) * Math.PI * this.radius ** 3;
  }

  /**
   * The axis-aligned bounding box of the sphere.
   */
  public get bounds() {
    return (this.#bounds ??= Object.freeze(this.calculateBounds()));
  }

  /**
   * The geometric centre of the sphere.
   */
  public get centroid() {
    return this.coords;
  }

  /**
   * Returns a deep clone of the sphere.
   */
  public clone() {
    return new Sphere(new Vector3(this.coords.x, this.coords.y, this.coords.z), this.radius);
  }

  /**
   * Returns the closest point on the sphere's surface to a given point.
   * @param point The point to project onto the sphere.
   */
  public closestPoint(point: Vector3) {
    const direction = point.clone().subtract(this.coords);
    const distance = direction.length();

    if (distance === 0) {
      direction.x = this.coords.x + this.radius;
      direction.y = this.coords.y;
      direction.z = this.coords.z;

      return direction;
    }

    direction.multiply(this.radius / distance);

    return direction.add(this.coords);
  }
}

/**
 * Represents a 2D polygon.
 */
export class Polygon implements Shape2D {
  readonly vertices: ReadonlyArray<Readonly<Vector2>>;
  #signedArea?: number;
  #bounds?: Readonly<Bounds2D>;
  #centroid?: Readonly<Vector2>;
  #triangles?: ReadonlyArray<[Readonly<Vector2>, Readonly<Vector2>, Readonly<Vector2>]>;

  /**
   * Creates a new 2D polygon.
   * @param vertices An array containing at least 3 vertices.
   */
  constructor(vertices: Vector2[]) {
    if (vertices.length < 3) throw new Error('A polygon requires at least 3 vertices.');

    if (!vertices.every((v) => Number.isFinite(v.x) && Number.isFinite(v.y)))
      throw new RangeError('Polygon coordinates must be finite.');

    for (let i = 0; i < vertices.length; i++) {
      const a = vertices[i]!;
      const b = vertices[(i + 1) % vertices.length]!;
      if (a.x === b.x && a.y === b.y) throw new Error('Consecutive polygon vertices must be distinct.');
    }

    this.vertices = Object.freeze(vertices.map((v) => Object.freeze(new Vector2(v.x, v.y))));

    if (this.calculateArea() === 0) throw new Error('Polygon area must be nonzero.');
  }

  /**
   * Calculates the area of the polygon using the shoelace formula.
   *
   * @param signed If `true` returns the signed area, otherwise returns the absolute area of the polygon.
   */
  public calculateArea(signed = false) {
    const vertices = this.vertices;
    let area = 0;

    for (let i = 0, j = vertices.length - 1; i < vertices.length; j = i++) {
      const { x: ax, y: ay } = vertices[i]!;
      const { x: bx, y: by } = vertices[j]!;

      area += ax * by - bx * ay;
    }

    area /= 2;

    return signed ? area : Math.abs(area);
  }

  /**
   * Calculates the axis-aligned bounding box of the polygon.
   */
  public calculateBounds() {
    let [minX, maxX] = [Infinity, -Infinity];
    let [minY, maxY] = [Infinity, -Infinity];

    for (const v of this.vertices) {
      if (v.x < minX) minX = v.x;
      if (v.y < minY) minY = v.y;
      if (v.x > maxX) maxX = v.x;
      if (v.y > maxY) maxY = v.y;
    }

    return { minX, minY, maxX, maxY };
  }

  /**
   * Calculates the geometric centre of the polygon.
   */
  public calculateCentroid() {
    const vertices = this.vertices;
    let x = 0;
    let y = 0;

    for (let i = 0, j = vertices.length - 1; i < vertices.length; j = i++) {
      const { x: ax, y: ay } = vertices[i]!;
      const { x: bx, y: by } = vertices[j]!;
      const cross = ax * by - bx * ay;

      x += (ax + bx) * cross;
      y += (ay + by) * cross;
    }

    const f = 1 / (6 * this.signedArea);

    return new Vector2(x * f, y * f);
  }

  public calculateTriangles() {
    const triangles: [Readonly<Vector2>, Readonly<Vector2>, Readonly<Vector2>][] = [];

    if (this.isConvex()) {
      for (let i = 1; i < this.vertices.length - 1; i++) {
        triangles.push([this.vertices[0]!, this.vertices[i]!, this.vertices[i + 1]!]);
      }

      return triangles;
    }

    const isCCW = this.signedArea > 0;
    const indices = Array.from({ length: this.vertices.length }, (_, i) => (isCCW ? this.vertices.length - 1 - i : i));

    while (true) {
      let foundEar = false;

      for (let i = 0; i < indices.length; i++) {
        const i1 = indices[(i - 1 + indices.length) % indices.length]!;
        const i2 = indices[i]!;
        const i3 = indices[(i + 1) % indices.length]!;
        const a = this.vertices[i1]!;
        const b = this.vertices[i2]!;
        const c = this.vertices[i3]!;
        const cross = Polygon.cross(a, b, c);

        if (cross <= 0) continue;

        let isEar = true;

        for (let j = 0; j < indices.length; j++) {
          const idx = indices[j]!;

          if (idx === i1 || idx === i2 || idx === i3) continue;

          const p = this.vertices[idx]!;
          const c1 = Polygon.cross(a, b, p);
          const c2 = Polygon.cross(b, c, p);
          const c3 = Polygon.cross(c, a, p);
          const hasNeg = c1 < 0 || c2 < 0 || c3 < 0;
          const hasPos = c1 > 0 || c2 > 0 || c3 > 0;
          const pointInTriangle = !(hasNeg && hasPos);

          if (pointInTriangle) {
            isEar = false;
            break;
          }
        }

        if (isEar) {
          foundEar = true;

          triangles.push([a, b, c]);
          indices.splice(i, 1);
          break;
        }
      }

      if (!foundEar) {
        throw new Error('Triangulation failed: possible non-simple or degenerate polygon.');
      }

      if (indices.length === 3) {
        const [i1, i2, i3] = indices;

        triangles.push([this.vertices[i1!]!, this.vertices[i2!]!, this.vertices[i3!]!]);

        break;
      }
    }

    return triangles;
  }

  /**
   * The absolute area of the polygon.
   */
  public get area() {
    return Math.abs(this.signedArea);
  }

  /**
   * The signed area of the polygon.
   */
  public get signedArea() {
    return (this.#signedArea ??= this.calculateArea(true));
  }

  /**
   * The axis-aligned bounding box of the polygon.
   */
  public get bounds() {
    return (this.#bounds ??= Object.freeze(this.calculateBounds()));
  }

  /**
   * The geometric centre of the polygon.
   */
  public get centroid() {
    return (this.#centroid ??= Object.freeze(this.calculateCentroid()));
  }

  public get triangles() {
    return (this.#triangles ??= Object.freeze(this.calculateTriangles()));
  }

  /**
   * Returns a deep clone of the polygon.
   */
  public clone() {
    return new Polygon(this.vertices.map((v) => new Vector2(v.x, v.y)));
  }

  /**
   * Checks if a point (x, y) lies within the polygon using the ray-casting algorithm.
   * @param x The x coordinate of the point.
   * @param y The y coordinate of the point.
   */
  public contains(x: number, y: number) {
    const vertices = this.vertices;
    let inside = false;

    for (let i = 0, j = vertices.length - 1; i < vertices.length; j = i++) {
      const { x: ax, y: ay } = vertices[i]!;
      const { x: bx, y: by } = vertices[j]!;

      // Include points on the polygon boundary, matching the other shapes.
      if (
        (x - ax) * (by - ay) === (y - ay) * (bx - ax) &&
        x >= Math.min(ax, bx) &&
        x <= Math.max(ax, bx) &&
        y >= Math.min(ay, by) &&
        y <= Math.max(ay, by)
      )
        return true;

      const intersect = ay > y !== by > y && x < ((bx - ax) * (y - ay)) / (by - ay || Number.EPSILON) + ax;

      if (intersect) inside = !inside;
    }

    return inside;
  }

  /**
   * Returns the closest point on the polygon's edges to a given point.
   * @param point The point to project onto the polygon.
   */
  public closestPoint(point: Vector) {
    const closestPoint = new Vector2();
    const edgeVector = new Vector2();
    const pointVector = new Vector2();
    const projectedPoint = new Vector2();
    const vertices = this.vertices;
    let minDistanceSq = Infinity;

    for (let i = 0, j = vertices.length - 1; i < vertices.length; j = i++) {
      const startVertex = vertices[j]!;
      const endVertex = vertices[i]!;

      edgeVector.x = endVertex.x - startVertex.x;
      edgeVector.y = endVertex.y - startVertex.y;

      pointVector.x = point.x - startVertex.x;
      pointVector.y = point.y - startVertex.y;

      const factor = clamp(pointVector.dot(edgeVector) / edgeVector.lengthSquared(), 0, 1);

      projectedPoint.x = startVertex.x + edgeVector.x * factor;
      projectedPoint.y = startVertex.y + edgeVector.y * factor;

      const distanceSq = projectedPoint.distanceSquared(point);

      if (distanceSq < minDistanceSq) {
        minDistanceSq = distanceSq;
        closestPoint.copy(projectedPoint);
      }
    }

    return closestPoint;
  }

  /**
   * Calculates the cross product of three points.
   */
  public static cross(a: Point2D, b: Point2D, c: Point2D) {
    return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
  }

  /**
   * Determines if the polygon is convex.
   */
  public isConvex() {
    const vertices = this.vertices;
    const n = vertices.length;
    let sign = 0;

    for (let i = 0; i < n; i++) {
      const a = vertices[i]!;
      const b = vertices[(i + 1) % n]!;
      const c = vertices[(i + 2) % n]!;
      const cross = Polygon.cross(a, b, c);

      if (cross !== 0) {
        const currentSign = cross > 0 ? 1 : -1;

        if (sign === 0) {
          sign = currentSign;
        } else if (sign !== currentSign) {
          return false;
        }
      }
    }

    return true;
  }
}

/**
 * Represents a 3D prism formed by extruding a 2D polygon along the Z axis.
 */
export class Prism {
  /**
   * Creates a rectangular prism extending out from the origin coordinates.
   *
   * @param origin The centre position of the prism.
   * @param width  The length of the prism along the X axis.
   * @param depth  The length of the prism along the Y axis.
   * @param height The length of the prism along the Z axis.
   * @param heading Rotation of the prism in degrees.
   */
  static createCuboid(origin: Vector3, width: number, depth: number, height: number, heading = 0) {
    let { x, y, z } = origin;
    const hw = width / 2;
    const hd = depth / 2;

    const vertices = [
      new Vector2(x - hw, y - hd),
      new Vector2(x + hw, y - hd),
      new Vector2(x + hw, y + hd),
      new Vector2(x - hw, y + hd),
    ];

    if (heading) {
      const rad = (heading * Math.PI) / 180;
      const cos = Math.cos(rad);
      const sin = Math.sin(rad);

      vertices.forEach((v) => {
        const dx = v.x - x;
        const dy = v.y - y;

        v.x = x + dx * cos - dy * sin;
        v.y = y + dx * sin + dy * cos;
      });
    }

    height = Math.abs(height);

    return new Prism(vertices, height, z);
  }

  readonly z: number;
  readonly height: number;
  readonly polygon: Polygon;
  #bounds?: Readonly<Bounds3D>;
  #centroid?: Readonly<Vector3>;

  /**
   * Creates a new extruded polygon.
   * @param vertices An array containing at least 3 vertices.
   * @param height Total height of the prism.
   * @param z The centre Z position of the prism.
   */
  constructor(vertices: Vector2[], height: number, z: number) {
    if (!Number.isFinite(height) || height <= 0 || !Number.isFinite(z))
      throw new RangeError('Height must be positive and finite, and Z must be finite.');

    this.polygon = new Polygon(vertices);
    this.z = z;
    this.height = height;
  }

  /**
   * The axis-aligned bounding box of the extruded polygon.
   */
  public get bounds() {
    return (this.#bounds ??= Object.freeze(this.calculateBounds()));
  }

  /**
   * The geometric centre of the extruded polygon.
   */
  public get centroid() {
    return (this.#centroid ??= Object.freeze(this.calculateCentroid()));
  }

  /**
   * The volume of the extruded polygon.
   */
  public get volume() {
    return this.polygon.area * this.height;
  }

  /**
   * Returns a deep clone of the extruded polygon.
   */
  public clone() {
    return new Prism(
      this.polygon.vertices.map((v) => new Vector2(v.x, v.y)),
      this.height,
      this.z,
    );
  }

  /**
   * Calculates the axis-aligned bounding box of the extruded polygon.
   */
  public calculateBounds() {
    const bounds = this.polygon.calculateBounds() as Bounds3D;
    const half = this.height / 2;
    bounds.minZ = this.z - half;
    bounds.maxZ = this.z + half;

    return bounds;
  }

  /**
   * Calculates the geometric centre of the extruded polygon.
   */
  public calculateCentroid() {
    const { x, y } = this.polygon.calculateCentroid();
    return new Vector3(x, y, this.z);
  }

  /**
   * Checks if a point (x, y, z) lies within the extruded polygon.
   * @param x The x coordinate of the point.
   * @param y The y coordinate of the point.
   * @param z The z coordinate of the point.
   */
  public contains(x: number, y: number, z: number) {
    const half = this.height / 2;

    if (z < this.z - half || z > this.z + half) return false;

    return this.polygon.contains(x, y);
  }

  /**
   * Returns the closest point on the prism's surface to a given point.
   * @param point The 3D point to project onto the prism.
   */
  public closestPoint(point: Vector3) {
    const [x, y] = this.polygon.closestPoint(point);
    const half = this.height / 2;
    const z = clamp(point.z, this.z - half, this.z + half);

    const side = new Vector3(x, y, z);
    const capZ = point.z < this.z ? this.z - half : this.z + half;
    const cap = this.polygon.contains(point.x, point.y) ? new Vector3(point.x, point.y, capZ) : new Vector3(x, y, capZ);

    return point.distance(cap) < point.distance(side) ? cap : side;
  }
}

console.warn(`The ox_lib zones module is experimental and may change in future versions.`);

import { Grid } from '@overextended/core/grid';
import { Cylinder, Prism, Sphere } from '@overextended/core/geometry';
import { Vector2, Vector3 } from '@overextended/core/vector';
import { cache } from '../cache';

type Shapes = Prism | Sphere | Cylinder;

export interface Zone {
  id: string;
  shape: Shapes;
  x: number;
  y: number;
  width: number;
  height: number;
  inside?: () => void;
  onEnter?: () => void;
  onExit?: () => void;
}

export class Zone {
  private static nextId = 1;

  public static map = new Map<string, Zone>();
  public static grid = new Grid<Zone>();

  public static Prism(...args: ConstructorParameters<typeof Prism>) {
    return new Zone(new Prism(...args));
  }

  public static Cuboid(...args: Parameters<(typeof Prism)['createCuboid']>) {
    return new Zone(Prism.createCuboid(...args));
  }

  public static Sphere(...args: ConstructorParameters<typeof Sphere>) {
    return new Zone(new Sphere(...args));
  }

  public static delete(id: string) {
    const zone = Zone.map.get(id);

    if (zone) {
      Zone.map.delete(id);
      Zone.grid.remove(zone);
    }
  }

  public static getNearby(point: Vector2 | Vector3) {
    return Zone.grid.getEntries(point.x, point.y);
  }

  public static has(id: string) {
    return Zone.map.has(id);
  }

  public shouldDraw = false;

  private constructor(shape: Shapes) {
    this.shape = shape;
    this.x = shape.centroid.x;
    this.y = shape.centroid.y;
    this.id = `zone:${Zone.nextId++}`;

    if (shape instanceof Prism) {
      const bounds = shape.bounds;
      this.width = Math.abs(bounds.maxX - bounds.minX);
      this.height = Math.abs(bounds.maxY - bounds.minY);
    } else {
      const diametre = ('circle' in shape ? shape.circle.radius : shape.radius) * 2;

      this.width = diametre;
      this.height = diametre;
    }

    Zone.grid.add(this);
    Zone.map.set(this.id, this);
  }

  public draw(red = 255, green = 42, blue = 24, alpha = 100) {
    if (cache.game === 'fxserver') return;

    if (this.shape instanceof Sphere) {
      const { x, y, z } = this.shape.coords;
      const radius = this.shape.radius;

      return DrawMarker(
        28,
        x,
        y,
        z,
        0,
        0,
        0,
        0,
        0,
        0,
        radius,
        radius,
        radius,
        red,
        green,
        blue,
        alpha,
        false,
        false,
        0,
        false,
        null as any,
        null as any,
        false
      );
    }

    if (this.shape instanceof Prism) {
      const polygon = this.shape.polygon;
      const half = this.shape.height / 2;
      const minZ = this.shape.z - half;
      const maxZ = this.shape.z + half;

      for (let i = 0; i < polygon.vertices.length; i++) {
        const curr = polygon.vertices[i]!;
        const next = (polygon.vertices[i + 1] || polygon.vertices[0])!;

        DrawLine(curr.x, curr.y, minZ, curr.x, curr.y, maxZ, red, green, blue, 225);
        DrawLine(curr.x, curr.y, maxZ, next.x, next.y, maxZ, red, green, blue, 225);
        DrawLine(curr.x, curr.y, minZ, next.x, next.y, minZ, red, green, blue, 225);

        DrawPoly(curr.x, curr.y, minZ, curr.x, curr.y, maxZ, next.x, next.y, maxZ, red, green, blue, alpha);
        DrawPoly(curr.x, curr.y, minZ, next.x, next.y, maxZ, next.x, next.y, minZ, red, green, blue, alpha);
        DrawPoly(curr.x, curr.y, minZ, next.x, next.y, maxZ, curr.x, curr.y, maxZ, red, green, blue, alpha);
        DrawPoly(curr.x, curr.y, minZ, next.x, next.y, minZ, next.x, next.y, maxZ, red, green, blue, alpha);
      }

      for (let i = 0; i < polygon.triangles.length; i++) {
        const [a, b, c] = polygon.triangles[i]!;

        DrawPoly(a.x, a.y, minZ, b.x, b.y, minZ, c.x, c.y, minZ, red, green, blue, alpha);
        DrawPoly(a.x, a.y, maxZ, b.x, b.y, maxZ, c.x, c.y, maxZ, red, green, blue, alpha);
        DrawPoly(b.x, b.y, minZ, a.x, a.y, minZ, c.x, c.y, minZ, red, green, blue, alpha);
        DrawPoly(b.x, b.y, maxZ, a.x, a.y, maxZ, c.x, c.y, maxZ, red, green, blue, alpha);
      }

      return;
    }
  }
}

function startPolling() {
  if (cache.game === 'fxserver') return;

  let nearbyZones = new Set<Zone>() as ReadonlySet<Zone>;
  let insideZones = new Set<Zone>();
  let lastZones = new Set<Zone>();

  setInterval(() => {
    const coords = Vector3.fromArray(GetEntityCoords(cache.ped, true));
    cache.coords = coords;
    nearbyZones = Zone.getNearby(coords);
    [lastZones, insideZones] = [insideZones, lastZones];
    insideZones.clear();

    for (const zone of nearbyZones) {
      if (zone.shape.contains(coords.x, coords.y, coords.z)) {
        insideZones.add(zone);

        if (!lastZones.has(zone)) {
          if (zone.onEnter) zone.onEnter();
        } else {
          lastZones.delete(zone);
        }
      }
    }

    for (const zone of lastZones) {
      if (zone.onExit) zone.onExit();
    }
  }, 300);

  setTick(() => {
    for (const zone of nearbyZones) {
      if (zone.shouldDraw) zone.draw();
    }

    for (const zone of insideZones) {
      if (zone.inside) zone.inside();
    }
  });
}

startPolling();

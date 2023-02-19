import { Vector3 } from '@nativewrappers/client';

let points: Point[] = [];
let nearbyPoints: Point[] = [];
let nearbyCount: number = 0;
let closestPoint: Point | undefined;
let tick: number | undefined;

interface LibPoint {
  coords: number[];
  distance: number;
  onEnter?: () => void;
  onExit?: () => void;
  nearby?: () => void;
}

export class Point {
  id: number = 0;
  coords: Vector3;
  distance: number = 0;
  onEnter?: () => void;
  onExit?: () => void;
  nearby?: () => void;
  inside: boolean = false;
  currentDistance?: number;
  isClosest: boolean = false;

  constructor(point: LibPoint) {
    this.id = points.length + 1;
    this.coords = Vector3.fromArray(point.coords);
    this.distance = point.distance;
    this.onEnter = point.onEnter;
    this.onExit = point.onExit;
    this.nearby = point.nearby;
    points.push(this);
  }

  remove = () => {
    points = points.filter((point) => point.id !== this.id);
  };
}

setInterval(() => {
  if (nearbyCount !== 0) {
    nearbyPoints = [];
    nearbyCount = 0;
  }

  const coords = Vector3.fromArray(GetEntityCoords(PlayerPedId(), false));

  if (closestPoint && coords.distance(closestPoint.coords) > closestPoint.distance) {
    closestPoint = undefined;
  }

  for (let i = 0; i < points.length; i++) {
    const point = points[i];
    const distance = coords.distance(point.coords);

    if (distance <= point.distance) {
      point.currentDistance = distance;

      if (closestPoint && closestPoint.currentDistance) {
        if (distance < closestPoint.currentDistance) {
          closestPoint.isClosest = false;
          point.isClosest = true;
          closestPoint = point;
        }
      } else if (distance < point.distance) {
        point.isClosest = true;
        closestPoint = point;
      }

      if (point.nearby) {
        nearbyCount++;
        nearbyPoints[nearbyCount - 1] = point;
      }

      if (point.onEnter && !point.inside) {
        point.inside = true;
        point.onEnter();
      }
    } else if (point.currentDistance) {
      if (point.onExit) point.onExit();
      point.inside = false;
      point.currentDistance = undefined;
    }
  }

  if (!tick) {
    if (nearbyCount !== 0) {
      tick = setTick(() => {
        for (let i = 0; i < nearbyCount; i++) {
          const point = nearbyPoints[i];

          if (point && point.nearby) {
            point.nearby();
          }
        }
      });
    }
  } else if (nearbyCount === 0) {
    clearTick(tick);
    tick = undefined;
  }
}, 300);

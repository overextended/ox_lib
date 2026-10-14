export interface MashGameData {
  durations: number | number[];
  keys?: string[];
  decayRate?: number;
  failOnWrongKey?: boolean;
  timeout?: number | number[];
}

export * from './resource';

// https://www.raygesualdo.com/posts/flattening-object-keys-with-typescript-types/
export type FlattenObjectKeys<T extends Record<string, unknown>, Key = keyof T> = Key extends string
  ? T[Key] extends Record<string, unknown>
    ? `${Key}.${FlattenObjectKeys<T[Key]>}`
    : `${Key}`
  : never;

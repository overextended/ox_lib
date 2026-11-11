import { KvpStore } from "./kvp";

export class Character {
  static Kvp = new KvpStore("character", "char_id");

  constructor(public id: number) {}

  set(key: string, value: any) {
    return Character.Kvp.set(this.id, key, value);
  }

  get(...keys: string[]) {
    return Character.Kvp.get(this.id, ...keys);
  }
}

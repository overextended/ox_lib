import { decode, encode } from "node:querystring";
import { db, prepare } from "./sqlite";

export class KvpStore {
  public table: string;
  public id_col: string;

  constructor(table: string, id_col = `${table}_id`) {
    this.table = `${table}_kvp`;
    this.id_col = id_col;

    db.exec(`
      CREATE TABLE IF NOT EXISTS "${this.table}"(
        "${this.id_col}" INTEGER NOT NULL,
        "key" TEXT NOT NULL,
        "value" TEXT NOT NULL,
        PRIMARY KEY("${this.id_col}", "key"),
        FOREIGN KEY("${this.id_col}") REFERENCES "${table}"("id")
          ON UPDATE CASCADE
          ON DELETE CASCADE
      );
    `);
  }

  set(charId: number, key: string, value: any) {
    return (
      prepare(`
      INSERT INTO ${this.table} (${this.id_col}, key, value)
        VALUES (?, ?, ?)
      ON CONFLICT (${this.id_col}, key) DO
        UPDATE SET value = excluded.value;
    `).run(charId, key, encode(value))?.changes > 0
    );
  }

  get(charId: number, ...keys: string[]): Record<string, any> {
    const placeholders = keys.map(() => "?").join(", ");

    return db
      .prepare(`SELECT key, value FROM ${this.table} WHERE ${this.id_col} = ? AND key IN (${placeholders})`)
      .all(charId, ...keys)
      .reduce((acc: Record<string, any>, { key, value }: { key: string; value: any }) => {
        acc[key] = decode(value);
        return acc;
      }, {});
  }
}

import { cache } from "@overextended/ox_lib/server";
import type { SQLInputValue, StatementSync } from "node:sqlite";

const { DatabaseSync } = require("node:sqlite");

const dbPath = "ox.db";
export const db = new DatabaseSync(dbPath);
export const dbr = new DatabaseSync(dbPath, { readOnly: true });

db.exec(`
  PRAGMA journal_mode = WAL;
  PRAGMA synchronous = NORMAL;
  PRAGMA journal_size_limit = 16777216;
  PRAGMA mmap_size = 134217728;
  PRAGMA cache_size = -8192;
  PRAGMA foreign_keys = ON;
`);

dbr.exec(`
  PRAGMA mmap_size = 134217728;
  PRAGMA cache_size = -8192;
  PRAGMA foreign_keys = ON;
`);

db.exec(LoadResourceFile(cache.resource, "resource/db.sql"));

const statements = new Map<string, StatementSync>();

export function prepare(sql: string) {
  return statements.get(sql) ?? statements.set(sql, db.prepare(sql)).get(sql)!;
}

export function encode(value: SQLInputValue) {
  return JSON.stringify(value);
}

export function decode(value: string) {
  return JSON.parse(value);
}

/**
 * Experimental user management for ox_lib
 * Currently intended for internal use only
 * Note: Resource internals (including this) need to be rewritten into TS eventually (v4?)
 */

//@ts-nocheck

const { DatabaseSync } = require("node:sqlite");

const dbPath = "ox.db";
const resource = GetCurrentResourceName();
const sqlite = new DatabaseSync(dbPath);

sqlite.exec(`
  PRAGMA journal_mode = WAL;
  PRAGMA synchronous = NORMAL;
  PRAGMA journal_size_limit = 16777216;
  PRAGMA mmap_size = 134217728;
  PRAGMA cache_size = -8192;
  PRAGMA foreign_keys = ON;
`);

sqlite.exec(LoadResourceFile(resource, "resource/db.sql"));

// const readonly = new DatabaseSync(dbPath, { readOnlyrue });
//
// readonly.exec(`
//   PRAGMA mmap_size = 134217728;
//   PRAGMA cache_size = -8192;
//   PRAGMA foreign_keys = ON;
// `);

// const dbFindOne = (query = "", parameters = []) => readonly.prepare(query).get(parameters);
// const dbFindAll = (query = "", parameters = []) => readonly.prepare(query).all(parameters);
//
// exports("dbFindOne", dbFindOne);
// exports("dbFindAll", dbFindAll);

const SV_LAN = GetConvarBool("SV_LAN", false);

function GetPlayerLicense(playerId) {
  const license = GetPlayerIdentifierByType(playerId, "license");

  if (license || !SV_LAN) return license;

  return `temp${GetHashKey(GetPlayerIdentifierByType(playerId, "ip")).toString(16).padStart(36, "0")}`;
}

function encode(value) {
  return JSON.stringify(value);
}

function decode(value) {
  return JSON.parse(value);
}

class KvpStore {
  constructor(table, id_col = `${table}_id`) {
    this.table = `${table}_kvp`;
    this.id_col = id_col;

    sqlite.exec(`
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

  set(charId, key, value) {
    return (
      prepare(`
      INSERT INTO ${this.table} (${this.id_col}, key, value)
        VALUES (?, ?, ?)
      ON CONFLICT (${this.id_col}, key) DO
        UPDATE SET value = excluded.value;
    `).run(charId, key, encode(value))?.changes > 0
    );
  }

  get(charId, ...keys) {
    const placeholders = keys.map(() => "?").join(", ");

    return sqlite
      .prepare(`SELECT key, value FROM ${this.table} WHERE ${this.id_col} = ? AND key IN (${placeholders})`)
      .all(charId, ...keys)
      .reduce((acc, { key, value }) => {
        acc[key] = decode(value);
        return acc;
      }, {});
  }
}

//@todo use a lru cache
const statements = new Map();

function prepare(sql) {
  return statements.get(sql) ?? statements.set(sql, sqlite.prepare(sql)).get(sql);
}

class User {
  static Kvp = new KvpStore("user");
  static Registry = new Map();

  constructor(playerId) {
    playerId = +playerId;
    const license = GetPlayerLicense(playerId);

    if (!license) {
      throw new Error(`player:${playerId} has no valid license.`);
    }

    const { id } = prepare(`
      INSERT INTO user (license, last_seen)
        VALUES (?, unixepoch())
      ON CONFLICT (license) DO
        UPDATE SET last_seen = unixepoch()
      RETURNING id
    `).get(license);

    getPlayerTokens(playerId).forEach((token) =>
      prepare(`INSERT OR IGNORE INTO user_tokens (user_id, token, last_seen) VALUES (?, ?, unixepoch())`).run(
        user.id,
        token,
      ),
    );

    this.id = id;
    this.license = license;
    this.playerId = playerId;

    User.Registry.set(playerId, this);
  }

  set(key, value) {
    return User.Kvp.set(this.id, key, value);
  }

  get(keys) {
    return User.Kvp.get(this.id, keys);
  }

  setCharacter(charId) {
    if (charId === -1) {
      const id =
        prepare(`SELECT id FROM character WHERE user_id = ? ORDER BY last_seen DESC LIMIT 1`).get(this.id)?.id ??
        this.addCharacter();
      this.character = new Character(id);

      return;
    } else if (typeof charId === "string") {
      const result = prepare(`
        SELECT id FROM character
        JOIN character_kvp kvp ON kvp.char_id = character.id
        WHERE character.user_id = ? AND kvp.key = 'fw-identifier' AND kvp.value = ?
      `).get(this.id, encode(charId));

      if (!result) {
        this.setCharacter(this.addCharacter());
        this.character.set("fw-identifier", charId);
      } else {
        this.setCharacter(result.id);
      }

      return;
    }

    const character = this.getCharacter(charId);

    if (!character) throw new Error(`user:${this.id} does not own character:${charId}.`);

    this.character = new Character(charId);
  }

  getCharacter(charId) {
    return prepare(`SELECT * FROM character WHERE user_id = ? AND id = ?`).get(this.id, charId);
  }

  getCharacters() {
    return prepare(`SELECT * FROM character WHERE user_id = ?`).all(this.id);
  }

  addCharacter() {
    return prepare(`INSERT INTO character(user_id, last_seen) VALUES (?, unixepoch()) RETURNING id`).get(this.id)?.id;
  }
}

class Character {
  static Kvp = new KvpStore("character", "char_id");

  constructor(charId) {
    this.id = charId;
  }

  set(key, value) {
    return Character.Kvp.set(this.id, key, value);
  }

  get(keys) {
    return Character.Kvp.get(this.id, keys);
  }
}

on("playerJoining", () => new User(source));
on("playerDropped", () => User.Registry.delete(source));

setTimeout(() =>
  getPlayers().forEach((playerId) => {
    const user = new User(playerId);
    user.setCharacter(-1);
  }),
);

on("esx:playerLoaded", (playerId, player) => {
  const user = User.Registry.get(playerId);
  user.setCharacter(player.identifier);
});

on("QBCore:Server:PlayerLoaded", (player) => {
  const user = User.Registry.get(PlayerData.source);
  user.setCharacter(player.PlayerData.citizenid);
});

// do these things not have events for character deletion?
// todo: ensure characters with esx identifiers / qbus citizenids get cleaned up

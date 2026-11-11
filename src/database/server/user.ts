import { Character } from "./character";
import { KvpStore } from "./kvp";
import { encode, prepare } from "./sqlite";

const SV_LAN = GetConvarBool("SV_LAN", false);

function GetPlayerLicense(playerId: string) {
  const license = GetPlayerIdentifierByType(playerId, "license");

  if (license || !SV_LAN) return license;

  return `temp${GetHashKey(GetPlayerIdentifierByType(playerId, "ip")).toString(16).padStart(36, "0")}`;
}

export class User {
  static Kvp = new KvpStore("user");
  static Registry = new Map<number, User>();

  public id: number;
  public license: string;
  public playerId: number;
  public character?: Character;

  constructor(playerId: string | number) {
    playerId = +playerId;
    const license = GetPlayerLicense(playerId as any);

    if (!license) {
      throw new Error(`player:${playerId} has no valid license.`);
    }

    const { id } = prepare(`
      INSERT INTO user (license, last_seen)
        VALUES (?, unixepoch())
      ON CONFLICT (license) DO
        UPDATE SET last_seen = unixepoch()
      RETURNING id
    `).get(license) as { id: number };

    getPlayerTokens(playerId).forEach((token) =>
      prepare(`INSERT OR IGNORE INTO user_tokens (user_id, token, last_seen) VALUES (?, ?, unixepoch())`).run(
        this.id,
        token,
      ),
    );

    this.id = id;
    this.license = license;
    this.playerId = playerId;

    User.Registry.set(playerId, this);
  }

  set(key: string, value: any) {
    return User.Kvp.set(this.id, key, value);
  }

  get(...keys: string[]) {
    return User.Kvp.get(this.id, ...keys);
  }

  setCharacter(charId: number | string) {
    if (charId === -1) {
      const id =
        (prepare(`SELECT id FROM character WHERE user_id = ? ORDER BY last_seen DESC LIMIT 1`).get(this.id)
          ?.id as number) ?? this.addCharacter();
      this.character = new Character(id);

      return;
    } else if (typeof charId === "string") {
      const result = prepare(`
        SELECT id FROM character
        JOIN character_kvp kvp ON kvp.char_id = character.id
        WHERE character.user_id = ? AND kvp.key = 'fw-identifier' AND kvp.value = ?
      `).get(this.id, encode(charId)) as { id: number };

      if (!result) {
        this.setCharacter(this.addCharacter());
        this.character?.set("fw-identifier", charId);
      } else {
        this.setCharacter(result.id);
      }

      return;
    }

    const character = this.getCharacter(charId);

    if (!character) throw new Error(`user:${this.id} does not own character:${charId}.`);

    this.character = new Character(charId);
  }

  getCharacter(charId: number) {
    return prepare(`SELECT * FROM character WHERE user_id = ? AND id = ?`).get(this.id, charId);
  }

  getCharacters() {
    return prepare(`SELECT * FROM character WHERE user_id = ?`).all(this.id);
  }

  addCharacter() {
    return prepare(`INSERT INTO character(user_id, last_seen) VALUES (?, unixepoch()) RETURNING id`).get(this.id)!
      .id! as number;
  }
}

/**
 * Experimental user management for ox_lib
 * Currently intended for internal use only
 * Note: Resource internals (including this) need to be rewritten into TS eventually (v4?)
 */

import { dbr } from "./sqlite";
import { User } from "./user";

global.exports("dbFindOne", (query = "", parameters = []) => dbr.prepare(query).get(parameters));
global.exports("dbFindAll", (query = "", parameters = []) => dbr.prepare(query).all(parameters));

on("playerJoining", () => new User(source));
on("playerDropped", () => User.Registry.delete(source));

setTimeout(
  () =>
    getPlayers().forEach((playerId) => {
      const user = new User(+playerId);
      user.setCharacter(-1);
    }),
  100,
);

on("esx:playerLoaded", (playerId: number, player: any) => {
  const user = User.Registry.get(playerId);

  if (!user) return;
  
  user.setCharacter(player.identifier);
});

on("QBCore:Server:PlayerLoaded", (player: any) => {
  const user = User.Registry.get(player.PlayerData.source);

  if (!user) return;
  
  user.setCharacter(player.PlayerData.citizenid);
});

// do these things not have events for character deletion?
// todo: ensure characters with esx identifiers / qbus citizenids get cleaned up

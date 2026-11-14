type SkillCheckDifficulty = 'easy' | 'medium' | 'hard' | { areaSize: number; speedMultiplier: number };

/** Starts a skill check with the supplied difficulty stages and optional input keys. */
export const skillCheck = (difficulty: SkillCheckDifficulty | SkillCheckDifficulty[], inputs?: string[]) =>
  exports.ox_lib.skillCheck(difficulty, inputs);

/** Reports whether a skill check is active. */
export const skillCheckActive = (): boolean => exports.ox_lib.skillCheckActive();

/** Cancels the current skill check, throwing if none is active. */
export const cancelSkillCheck = (): void => exports.ox_lib.cancelSkillCheck();

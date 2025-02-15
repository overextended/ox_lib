interface CustomGameDifficulty {
  areaSize: number;
  speedMultiplier: number;
}

export type GameDifficulty = 'easy' | 'medium' | 'hard' | CustomGameDifficulty;

export interface SkillCheckProps {
  angle: number;
  difficultyOffset: number;
  difficulty: GameDifficulty;
  keys?: string[];
  key: string;
}

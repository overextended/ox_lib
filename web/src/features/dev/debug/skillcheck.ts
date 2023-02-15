import { debugData } from '../../../utils/debugData';
import { GameDifficulty } from '../../../typings';

export const debugSkillCheck = () => {
  debugData<{ difficulty: GameDifficulty | GameDifficulty[]; inputs?: string[] }>([
    {
      action: 'startSkillCheck',
      data: {
        difficulty: ['easy', 'easy', 'hard'],
        inputs: ['W', 'A', 'S', 'D'],
      },
    },
  ]);
};

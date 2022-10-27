import { debugData } from '../../../utils/debugData';
import { GameDifficulty } from '../../skillcheck';

export const debugSkillCheck = () => {
  debugData<GameDifficulty | GameDifficulty[]>([
    {
      action: 'startSkillCheck',
      data: ['easy', 'easy', 'hard'],
    },
  ]);
};

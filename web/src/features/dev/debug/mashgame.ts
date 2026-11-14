import { debugData } from '../../../utils/debugData';
import { MashGameData } from '../../../typings';

export const debugMashGame = () => {
  debugData<MashGameData>([
    {
      action: 'startMashGame',
      data: {
        durations: [4000, 2000, 1000],
        keys: ['e', 'a', 's', 'd'],
        decayRate: 25,
        failOnWrongKey: true,
      },
    },
  ]);
};

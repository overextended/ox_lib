import { debugData } from '../../../utils/debugData';
import { CircleProgressbarProps, ProgressbarProps } from '../../../typings';

export const debugProgressbar = () => {
  debugData<ProgressbarProps>([
    {
      action: 'progress',
      data: {
        label: 'Using Lockpick',
        duration: 8000,
      },
    },
  ]);
};

export const debugCircleProgressbar = () => {
  debugData<CircleProgressbarProps>([
    {
      action: 'circleProgress',
      data: {
        position: 'bottom',
        duration: 8000,
        label: 'Using Armour',
        icon: 'https://cdn.discordapp.com/attachments/927291680380567614/1084275435828957194/100mllsd.png',
      },
    },
  ]);
};

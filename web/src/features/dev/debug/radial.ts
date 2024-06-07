import { debugData } from '../../../utils/debugData';
import type { RadialMenuItem } from '../../../typings';

export const debugRadial = () => {
  debugData<{ items: RadialMenuItem[]; sub?: boolean }>([
    {
      action: 'openRadialMenu',
      data: {
        items: [
          { icon: 'palette', label: 'Paint' },
          { iconWidth: 30, iconHeight: 30, icon: 'https://icon-library.com/images/white-icon-png/white-icon-png-18.jpg', label: 'External icon'},
          { icon: 'warehouse', label: 'Revoke Driving License' },
          { icon: 'palette', label: 'Give Details' },
          { icon: 'palette', label: 'Paint' },
          { icon: 'warehouse', label: 'Garage' },
        ],
      },
    },
  ]);
};

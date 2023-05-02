import { debugData } from '../../../utils/debugData';
import type { MenuItem } from '../../../typings';

export const debugRadial = () => {
  debugData<{ items: MenuItem[]; sub?: boolean }>([
    {
      action: 'openRadialMenu',
      data: {
        items: [
          { icon: 'palette', label: 'Paint' },
          { icon: 'warehouse', label: 'Garage' },
          { icon: 'palette', label: 'Quite long  \ntext' },
          { icon: 'palette', label: 'Paint' },
          { icon: 'warehouse', label: 'Garage' },
        ],
      },
    },
  ]);
};

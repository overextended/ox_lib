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
          { icon: 'palette', label: 'Quite long text' },
          { icon: 'building-shield', label: 'Police' },
          { icon: 'globe', label: 'General' },
          { icon: 'house', label: 'House' },
          { icon: 'car', label: 'Car' },
          { icon: 'users', label: 'Players' },
          { icon: 'paw', label: 'Pet' },
        ],
      },
    },
  ]);
};

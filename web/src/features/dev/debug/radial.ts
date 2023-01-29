import { debugData } from '../../../utils/debugData';
import type { MenuItem } from '../../menu/radial';

export const debugRadial = () => {
  debugData<{ items: MenuItem[]; sub?: boolean }>([
    {
      action: 'openRadialMenu',
      data: {
        items: [
          // TODO: Fix wheel being broken when there's only one item
          { icon: 'palette', label: 'Paint' },
          { icon: 'warehouse', label: 'Garage' },
          { icon: 'palette', label: 'Quite long text' },
          { icon: 'palette', label: 'Paint' },
          { icon: 'warehouse', label: 'Garage' },
        ],
      },
    },
  ]);
};

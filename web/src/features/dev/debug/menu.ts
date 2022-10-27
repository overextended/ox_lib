import { debugData } from '../../../utils/debugData';
import { MenuSettings } from '../../menu/list';

export const debugMenu = () => {
  debugData<MenuSettings>([
    {
      action: 'setMenu',
      data: {
        //   position: "bottom-left",
        title: 'Vehicle garage',
        items: [
          { label: 'Option 1', icon: 'heart' },
          {
            label: 'Option 2',
            icon: 'basket-shopping',
            description: 'Tooltip description 1',
          },
          {
            label: 'Vehicle class',
            values: [
              { label: 'nice', description: 'description 1' },
              { label: 'even nicer', description: 'description 2' },
              'pogchamp',
            ],
            icon: 'tag',
            description: 'Tooltip description 2',
          },
          { label: 'Option 1' },
          { label: 'Option 2' },
          {
            label: 'Vehicle class',
            values: ['Nice', 'Super nice', 'Extra nice'],
            defaultIndex: 1,
          },
          { label: 'Option 1' },
          { label: 'Option 2' },
          {
            label: 'Vehicle class',
            values: ['Nice', 'Super nice', 'Extra nice'],
          },
        ],
      },
    },
  ]);
};

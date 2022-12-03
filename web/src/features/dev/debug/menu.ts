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
            checked: true,
          },
          {
            label: 'Vehicle class',
            values: ['pogchamp', 'nice champ', { label: 'POGGERS', description: 'CHAMPPERS' }],
            icon: 'tag',
            description: 'Side scroll general description',
          },
          {
            label: 'Oil Level',
            progress: 30,
            icon: 'oil-can',
            colorScheme: 'orange',
            description: 'Remaining Oil: 30%',
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

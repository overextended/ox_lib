import { debugData } from '../../../utils/debugData';
import { AlertProps } from '../../dialog/AlertDialog';

export const debugAlert = () => {
  debugData<AlertProps>([
    {
      action: 'sendAlert',
      data: {
        header: 'Hello there',
        content: 'General kenobi  \n Markdown works',
        centered: true,
        cancel: true,
      },
    },
  ]);
};

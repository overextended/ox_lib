import { debugData } from '../../../utils/debugData';
import { AlertProps } from '../../../typings';

export const debugAlert = () => {
  debugData<AlertProps>([
    {
      action: 'sendAlert',
      data: {
        header: 'Hello there',
        content: 'General kenobi  \n Markdown works',
        centered: true,
        size: 'lg',
        overflow: true,
        cancel: true,
        // labels: {
        //   confirm: 'Ok',
        //   cancel: 'Not ok',
        // },
      },
    },
  ]);
};

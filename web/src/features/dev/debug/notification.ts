import { CustomNotificationProps, NotificationProps } from '../../notifications/NotificationWrapper';
import { debugData } from '../../../utils/debugData';

export const debugCustomNotification = () => {
  debugData<CustomNotificationProps>([
    {
      action: 'customNotify',
      data: {
        title: 'Success',
        description: 'Notification description',
        type: 'success',
      },
    },
  ]);
  debugData<CustomNotificationProps>([
    {
      action: 'customNotify',
      data: {
        title: 'Info',
        description: 'Notification description',
        type: 'info',
      },
    },
  ]);
  debugData<CustomNotificationProps>([
    {
      action: 'customNotify',
      data: {
        title: 'Error',
        description: 'Notification description',
        type: 'error',
      },
    },
  ]);
  debugData<CustomNotificationProps>([
    {
      action: 'customNotify',
      data: {
        title: 'Custom icon success',
        description: 'Notification description',
        type: 'success',
        icon: 'microchip',
      },
    },
  ]);
};

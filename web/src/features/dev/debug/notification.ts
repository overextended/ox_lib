import { CustomNotificationProps, NotificationProps } from '../../notifications/NotificationWrapper';
import { debugData } from '../../../utils/debugData';

export const debugNotification = () => {
  debugData<NotificationProps>([
    {
      action: 'notify',
      data: {
        description: 'Dunak is nerd',
        title: 'Dunak',
        id: 1,
      },
    },
  ]);
};

export const debugCustomNotification = () => {
  debugData<CustomNotificationProps>([
    {
      action: 'customNotify',
      data: {
        description: 'Dunak is nerd',
        icon: 'basket-shopping',
        style: {
          backgroundColor: '#2D3748',
          color: 'white',
        },
      },
    },
  ]);
};

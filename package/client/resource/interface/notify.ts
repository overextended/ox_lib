import { CSSProperties } from 'react';
import { IconName, IconPrefix } from '@fortawesome/fontawesome-common-types';

type NotificationPosition = 'top' | 'top-right' | 'top-left' | 'bottom' | 'bottom-right' | 'bottom-left';
type NotificationType = 'inform' | 'error' | 'success';

interface NotifyProps {
  id?: string;
  title?: string;
  description?: string;
  duration?: number;
  position?: NotificationPosition;
  type?: NotificationType;
  style?: CSSProperties;
  icon?: IconName | [IconPrefix, IconName];
  iconColor?: string;
}

export const notify = (data: NotifyProps): void => exports.ox_lib.notify(data);

interface DefaultNotifyProps {
  title?: string;
  description?: string;
  duration?: number;
  position?: NotificationPosition;
  status?: 'info' | 'warning' | 'success' | 'error';
  id?: number;
}

export const defaultNotify = (data: DefaultNotifyProps): void => exports.ox_lib.defaultNotify(data);

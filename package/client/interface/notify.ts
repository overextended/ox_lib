import type { Sx } from '@mantine/core';
import type { IconName, IconPrefix } from '@fortawesome/fontawesome-common-types';

type NotificationPosition =
  | 'top'
  | 'top-right'
  | 'top-left'
  | 'bottom'
  | 'bottom-right'
  | 'bottom-left'
  | 'center-right'
  | 'center-left';
type NotificationType = 'inform' | 'error' | 'success' | 'warning';
type IconAnimation = 'spin' | 'spinPulse' | 'spinReverse' | 'pulse' | 'beat' | 'fade' | 'beatFade' | 'bounce' | 'shake';

interface NotifyProps {
  id?: string | number;
  title?: string;
  description?: string;
  duration?: number;
  showDuration?: boolean;
  position?: NotificationPosition;
  type?: NotificationType;
  style?: Sx;
  icon?: IconName | [IconPrefix, IconName];
  iconColor?: string;
  iconAnimation?: IconAnimation;
  alignIcon?: 'top' | 'center';
  sound?: { bank?: string; set: string; name: string };
}

/** Displays a notification with the supplied text, appearance, and optional sound. */
export const notify = (data: NotifyProps): void => exports.ox_lib.notify(data);

// Keep for backwards compat with v2
interface DefaultNotifyProps {
  title?: string;
  description?: string;
  duration?: number;
  position?: NotificationPosition;
  status?: 'info' | 'warning' | 'success' | 'error';
  id?: number;
}

/** Displays a notification using the legacy v2 status options. */
export const defaultNotify = (data: DefaultNotifyProps): void => exports.ox_lib.defaultNotify(data);

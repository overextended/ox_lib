import type { IconName, IconPrefix } from '@fortawesome/fontawesome-common-types';
import { CSSProperties } from 'react';

type IconAnimation = 'spin' | 'spinPulse' | 'spinReverse' | 'pulse' | 'beat' | 'fade' | 'beatFade' | 'bounce' | 'shake';

interface OptionsProps {
  position?: 'right-center' | 'left-center' | 'top-center' | 'bottom-center';
  icon?: IconName | [IconPrefix, IconName];
  iconColor?: string;
  iconAnimation?: IconAnimation;
  style?: CSSProperties;
  alignIcon?: 'top' | 'center';
}

export const showTextUI = (text: string, options?: OptionsProps): void => exports.ox_lib.showTextUI(text, options);

export const hideTextUI = (): void => exports.ox_lib.hideTextUI();

export const isTextUIOpen = (): boolean => exports.ox_lib.isTextUIOpen();

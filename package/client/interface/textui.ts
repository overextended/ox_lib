import type { IconName, IconPrefix } from '@fortawesome/fontawesome-common-types';
import type { Properties as CSSProperties } from 'csstype';

type IconAnimation = 'spin' | 'spinPulse' | 'spinReverse' | 'pulse' | 'beat' | 'fade' | 'beatFade' | 'bounce' | 'shake';

interface OptionsProps {
  position?: 'right-center' | 'left-center' | 'top-center' | 'bottom-center';
  icon?: IconName | [IconPrefix, IconName];
  iconColor?: string;
  iconAnimation?: IconAnimation;
  style?: CSSProperties;
  alignIcon?: 'top' | 'center';
}

/** Shows text with optional positioning, icon, and styling. */
export const showTextUI = (text: string, options?: OptionsProps): void => exports.ox_lib.showTextUI(text, options);

/** Hides the current text UI. */
export const hideTextUI = (): void => exports.ox_lib.hideTextUI();

/** Queries whether the text UI is open. */
export const isTextUIOpen = (): boolean => exports.ox_lib.isTextUIOpen();

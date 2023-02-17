import { IconProp } from '@fortawesome/fontawesome-svg-core';
import React from 'react';

export type TextUiPosition = 'right-center' | 'left-center' | 'top-center';

export interface TextUiProps {
  text: string;
  position?: TextUiPosition;
  icon?: IconProp;
  iconColor?: string;
  style?: React.CSSProperties;
}

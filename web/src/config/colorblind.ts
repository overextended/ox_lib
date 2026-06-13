import type { MantineColor } from '@mantine/core';

export type ColorblindMode = 'off' | 'protanopia' | 'deuteranopia' | 'tritanopia' | 'achromatopsia';

const colorblindModes: Record<ColorblindMode, { primaryColor: MantineColor; primaryShade: 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9; skillAreaColor: MantineColor; skillAreaShade: 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9; indicatorColor: MantineColor; indicatorShade: 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 }> = {
  off: {
    primaryColor: 'blue',
    primaryShade: 6,
    skillAreaColor: 'blue',
    skillAreaShade: 6,
    indicatorColor: 'red',
    indicatorShade: 6,
  },
  protanopia: {
    primaryColor: 'cyan',
    primaryShade: 6,
    skillAreaColor: 'cyan',
    skillAreaShade: 6,
    indicatorColor: 'orange',
    indicatorShade: 6,
  },
  deuteranopia: {
    primaryColor: 'blue',
    primaryShade: 6,
    skillAreaColor: 'blue',
    skillAreaShade: 6,
    indicatorColor: 'orange',
    indicatorShade: 6,
  },
  tritanopia: {
    primaryColor: 'pink',
    primaryShade: 6,
    skillAreaColor: 'pink',
    skillAreaShade: 6,
    indicatorColor: 'green',
    indicatorShade: 6,
  },
  achromatopsia: {
    primaryColor: 'gray',
    primaryShade: 7,
    skillAreaColor: 'gray',
    skillAreaShade: 7,
    indicatorColor: 'yellow',
    indicatorShade: 4,
  },
};

export const getColorblindTheme = (mode: ColorblindMode) => colorblindModes[mode];

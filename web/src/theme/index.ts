import { MantineThemeOverride } from '@mantine/core';

export const theme: MantineThemeOverride = {
  colorScheme: 'dark',
  fontFamily: 'Roboto',
  shadows: { sm: '1px 1px 3px rgba(0, 0, 0, 0.5)' },
  components: {
    Button: {
      styles: {
        root: {
          border: 'none',
        },
      },
    },
  },
  colors: {
    discord: ["#FBFCFE", "#CAD2ED", "#9CACE1", "#7289DA", "#506BCA", "#3D57B3", "#384C94", "#32427B", "#2D3A66", "#283255"],
    qbox: ["#F7F7C1", "#F4F47B", "#F7F73B", "#FFFF00", "#C4C408", "#97970D", "#74740E", "#5A5A0F", "#45450E", "#36360D"],
    qbcore: ["#F6D4DB", "#EA879B", "#E64364", "#DC143C", "#A11531", "#761428", "#571220", "#40101A", "#2F0E14", "#230B10"],
    nosleep: ["#FAF8FE", "#DDCAFB", "#C29CFB", "#A970FF", "#924FF8", "#7F35EE", "#6E20E3", "#6221C6", "#5923AA", "#502492"],
    nopixel: ["#B8F6E6", "#73F3D2", "#34F7C5", "#00F9B9", "#08BF90", "#0C9370", "#0E7158", "#0E5845", "#0E4436", "#0D342A"],
  },
};

import { MantineThemeOverride, Paper } from '@mantine/core';

export const theme: MantineThemeOverride = {
  colorScheme: 'dark',
  fontFamily: 'Saira',
  shadows: { sm: '1px 1px 3px rgba(0, 0, 0, 0.5)' },
  radius: { xs: 6, sm: 6, md: 6, lg: 20, xl: 50 },
  components: {
    Button: {
      styles: {
        root: {
          border: 'none',
        },
      },
    },
    Modal: {
      styles: {
        modal: {
          backgroundColor: 'rgba(0, 0, 0, 0.7)',
          color: 'white',
        },
        root: {
          color: 'white',
        },
        title: {
          color: 'white',
        },
      },
    },
  },
};

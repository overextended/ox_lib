import { Box, createStyles, Text } from '@mantine/core';
import React from 'react';

const useStyles = createStyles((theme) => ({
  container: {
    textAlign: 'center',
    backgroundColor: 'transparent',
    width: 384,
    marginBottom: 16,
  },
  heading: {
    fontSize: 24,
    fontWeight: 700,
    color: '#FFFFFF',
    textAlign: 'left',
  },
}));

const Header: React.FC<{ title: string }> = ({ title }) => {
  const { classes } = useStyles();

  return (
    <Box className={classes.container}>
      <Text className={classes.heading}>{title}</Text>
    </Box>
  );
};

export default React.memo(Header);

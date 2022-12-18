import React from 'react';
import { Progress, Box, Text, createStyles } from '@mantine/core';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { fetchNui } from '../../utils/fetchNui';

export interface ProgressbarProps {
  label: string;
  duration: number;
}

const useStyles = createStyles((theme) => ({
  container: {
    width: 350,
    height: 45,
    position: 'absolute',
    bottom: '15%',
    left: '50%',
    transform: 'translate(-50%)',
    borderRadius: theme.radius.xs,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
  },
  bar: {
    height: '100%',
    borderRadius: theme.radius.xs,
    backgroundColor: theme.colors[theme.primaryColor][theme.fn.primaryShade()],
  },
  label: {
    maxWidth: 350,
    padding: 8,
    textOverflow: 'ellipsis',
    overflow: 'hidden',
    whiteSpace: 'nowrap',
    position: 'absolute',
    top: '50%',
    left: '50%',
    transform: 'translate(-50%, -50%)',
    fontSize: 20,
  },
}));

const Progressbar: React.FC = () => {
  const { classes } = useStyles();
  const [visible, setVisible] = React.useState(false);
  const [label, setLabel] = React.useState('');
  const [duration, setDuration] = React.useState(0);
  const [cancelled, setCancelled] = React.useState(false);

  const progressComplete = () => {
    setVisible(false);
    fetchNui('progressComplete');
  };

  const progressCancel = () => {
    setCancelled(true);
    setVisible(false);
  };

  useNuiEvent('progressCancel', progressCancel);

  useNuiEvent<ProgressbarProps>('progress', (data) => {
    setCancelled(false);
    setVisible(true);
    setLabel(data.label);
    setDuration(data.duration);
  });

  return (
    <>
      <Box className={classes.container}>
        <Box
          className={classes.bar}
          onAnimationEnd={progressComplete}
          sx={{
            width: '0%',
            animation: 'progress-bar linear',
            animationDuration: `${duration}ms`,
          }}
        />
        <Text className={classes.label}>{label}</Text>
      </Box>
    </>
  );
};

export default Progressbar;

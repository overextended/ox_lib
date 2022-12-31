import React from 'react';
import { Progress, Box, Text, createStyles } from '@mantine/core';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { fetchNui } from '../../utils/fetchNui';
import ScaleFade from '../../transitions/ScaleFade';

export interface ProgressbarProps {
  label: string;
  duration: number;
}

const useStyles = createStyles((theme) => ({
  container: {
    width: 350,
    height: 45,
    borderRadius: theme.radius.xs,
    backgroundColor: theme.colors.dark[5],
  },
  wrapper: {
    width: '100%',
    height: '20%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    bottom: 0,
    position: 'absolute',
  },
  bar: {
    height: '100%',
    borderRadius: theme.radius.xs,
    backgroundColor: theme.colors[theme.primaryColor][theme.fn.primaryShade()],
  },
  labelWrapper: {
    position: 'absolute',
    display: 'flex',
    width: 350,
    height: 45,
    alignItems: 'center',
    justifyContent: 'center',
  },
  label: {
    maxWidth: 350,
    padding: 8,
    textOverflow: 'ellipsis',
    overflow: 'hidden',
    whiteSpace: 'nowrap',
    fontSize: 20,
    textShadow: theme.shadows.sm,
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
      <Box className={classes.wrapper}>
        <ScaleFade visible={visible}>
          <Box className={classes.container}>
            <Box
              className={classes.bar}
              onAnimationEnd={progressComplete}
              sx={{
                animation: 'progress-bar linear',
                animationDuration: `${duration}ms`,
              }}
            >
              <Box className={classes.labelWrapper}>
                <Text className={classes.label}>{label}</Text>
              </Box>
            </Box>
          </Box>
        </ScaleFade>
      </Box>
    </>
  );
};

export default Progressbar;

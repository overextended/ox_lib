import React from 'react';
import { Box, createStyles, Text } from '@mantine/core';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { fetchNui } from '../../utils/fetchNui';
import ScaleFadeLazy from '../../transitions/ScaleFadeLazy';
import type { ProgressbarProps } from '../../typings';
import SlideUp from '../../transitions/SlideUp';


const useStyles = createStyles((theme) => ({
  background: {
    width: '100%',
    height: '100vh',
    background: `radial-gradient(ellipse at bottom, ${theme.colors[theme.primaryColor][theme.fn.primaryShade()]} 0%, transparent 20%)`,
  },
  container: {
    width: 350,
    height: 10,
    borderRadius: theme.radius.sm,
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    overflow: 'hidden',
    transition: 'all 1.5s transform ease',
    boxShadow: `0px 100vh 200vh 100vh ${theme.colors[theme.primaryColor][theme.fn.primaryShade()]}80`,
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
    backgroundColor: theme.colors[theme.primaryColor][theme.fn.primaryShade()],
  },
  labelWrapper: {
    position: 'absolute',
    display: 'flex',
    width: 350,
    height: 70,
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
    color: "#fff",
    textShadow: `0px 0px 5px rgba(255, 255, 255, 1)`,
  },
}));

const Progressbar: React.FC = () => {
  const { classes } = useStyles();
  const [visible, setVisible] = React.useState(false);
  const [label, setLabel] = React.useState('');
  const [duration, setDuration] = React.useState(0);

  useNuiEvent('progressCancel', () => setVisible(false));

  useNuiEvent<ProgressbarProps>('progress', (data) => {
    setVisible(true);
    setLabel(data.label);
    setDuration(data.duration);
  });

  return (
    <>
    {/* <SlideUp visible={visible}>
      <Box
        className={classes.background}
        opacity={0.6}
        style={{
        }}
      />
    </SlideUp> */}
      <Box className={classes.wrapper}>
        <SlideUp visible={visible} onExitComplete={() => fetchNui('progressComplete')}>

          <Box className={classes.container}>
            <Box
              className={classes.bar}
              onAnimationEnd={() => setVisible(false)}
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
        </SlideUp>
      </Box>
    </>
  );
};

export default Progressbar;

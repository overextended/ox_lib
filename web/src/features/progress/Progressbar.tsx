import React from 'react';
import { Box, createStyles, Text } from '@mantine/core';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { fetchNui } from '../../utils/fetchNui';
import ScaleFade from '../../transitions/ScaleFade';
import type { ProgressbarProps } from '../../typings';

const useStyles = createStyles((theme) => ({
  container: {
    display: 'none',
    zIndex: 5,
    color: '#fff',
    width: '15%',
    height: '2.8vh',
    position: 'fixed',
    bottom: '5%',
    left: 0,
    right: 0,
    marginLeft: 'auto',
    marginRight: 'auto',
    fontFamily: '"Fira Sans", sans-serif',
    backgroundColor: 'rgb(0, 0, 0, 0.55)',
    borderStyle: 'solid',
    borderWidth: '1px',
    borderColor: 'rgba(61, 63, 79, 0)',
    overflow: 'hidden',
  },
  wrapper: {
    width: '100%',
    height: '100%',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    position: 'relative',
  },
  bar: {
    backgroundColor: '#3377a4',
    backgroundImage: `linear-gradient(-45deg, rgba(3, 3, 3, 0.15) 25%, transparent 25%, transparent 50%, rgba(3, 3, 3, 0.15) 50%, rgba(19, 19, 19, 0.15) 75%, transparent 75%, transparent)`,
    backgroundSize: '40px 40px',
    animation: 'progress-bar-stripes 2s linear infinite',
    height: '100%',
    transition: 'width 0.3s ease-out',
    boxShadow: '0 0 10px rgba(12, 12, 12, 0.527)',
    position: 'relative', // Added to enable positioning of children
  },
  labelWrapper: {
    position: 'absolute',
    width: '100%',
    height: '100%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center', // Center the label
    boxSizing: 'border-box',
  },
  label: {
    fontSize: '1.5vh',
    color: 'rgb(255, 255, 255)',
    fontWeight: 600,
    textAlign: 'center',
    zIndex: 10,
  },
  percentage: {
    fontSize: '1.2vh',
    color: 'rgb(180, 180, 180)',
    fontWeight: 400,
    position: 'absolute', // Allows positioning inside the progress bar
    right: '5px', // Position near the right edge
    zIndex: 10,
  },
}));

const Progressbar: React.FC = () => {
  const { classes } = useStyles();
  const [visible, setVisible] = React.useState(false);
  const [label, setLabel] = React.useState('');
  const [duration, setDuration] = React.useState(0);
  const [progress, setProgress] = React.useState(0); // Track progress percentage

  useNuiEvent('progressCancel', () => setVisible(false));

  useNuiEvent<ProgressbarProps>('progress', (data) => {
    setVisible(true);
    setLabel(data.label);
    setDuration(data.duration);

    const updateProgress = () => {
      let startTime = Date.now();
      const interval = setInterval(() => {
        let elapsed = Date.now() - startTime;
        let percentage = Math.min((elapsed / data.duration) * 100, 100);
        setProgress(percentage);

        if (percentage === 100) {
          clearInterval(interval);
          setVisible(false);
        }
      }, 50);
    };

    updateProgress();
  });

  return (
    <>
      <Box className={classes.wrapper}>
        <ScaleFade visible={visible} onExitComplete={() => fetchNui('progressComplete')}>
          <Box className={classes.container} style={{ display: visible ? 'block' : 'none' }}>
            <Box className={classes.labelWrapper}>
              <Text className={classes.label}>{label}</Text>
            </Box>
            <Box className={classes.bar} style={{ width: `${progress}%` }}> {/* Adjust width based on progress */}
              <Text className={classes.percentage}>{Math.round(progress)}%</Text> {/* Percentage text follows the progress bar */}
            </Box>
          </Box>
        </ScaleFade>
      </Box>
    </>
  );
};

export default Progressbar;

import React from 'react';
import { RingProgress, Text, useMantineTheme, keyframes, Stack, createStyles } from '@mantine/core';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { fetchNui } from '../../utils/fetchNui';

export interface CircleProgressbarProps {
  label?: string;
  duration: number;
  position?: 'middle' | 'bottom';
  percent?: boolean;
}

// 33.5 is the r of the circle
const progressCircle = keyframes({
  '0%': { strokeDasharray: `0, ${33.5 * 2 * Math.PI}` },
  '100%': { strokeDasharray: `${33.5 * 2 * Math.PI}, 0` },
});

const useStyles = createStyles((theme, params: { position: 'middle' | 'bottom'; duration: number }) => ({
  container: {
    position: 'absolute',
    top: params.position === 'middle' ? '50%' : undefined,
    bottom: params.position === 'bottom' ? '20%' : undefined,
    left: '50%',
    transform: 'translate(-50%, -50%)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  progress: {
    // Scuffed way of grabbing the first section and animating it
    '> svg > circle:nth-child(2)': {
      transition: 'none',
      animation: `${progressCircle} linear forwards`,
      animationDuration: `${params.duration}ms`,
    },
  },
  value: {
    textAlign: 'center',
    fontFamily: 'roboto-mono',
    textShadow: theme.shadows.sm,
  },
  label: {
    textAlign: 'center',
    textShadow: theme.shadows.sm,
  },
}));

const CircleProgressbar: React.FC = () => {
  const [visible, setVisible] = React.useState(false);
  const [progressDuration, setProgressDuration] = React.useState(0);
  const [position, setPosition] = React.useState<'middle' | 'bottom'>('middle');
  const [value, setValue] = React.useState(0);
  const [label, setLabel] = React.useState('');
  const theme = useMantineTheme();
  const { classes } = useStyles({ position, duration: progressDuration });

  const progressComplete = () => {
    setVisible(false);
    fetchNui('progressComplete');
  };

  const progressCancel = () => {
    setValue(99); // Sets the final value to 100% kek
    setVisible(false);
  };

  useNuiEvent('progressCancel', progressCancel);

  useNuiEvent<CircleProgressbarProps>('circleProgress', (data) => {
    if (visible) return;
    setVisible(true);
    setValue(0);
    setLabel(data.label || '');
    setProgressDuration(data.duration);
    setPosition(data.position || 'middle');
    const onePercent = data.duration * 0.01;
    const updateProgress = setInterval(() => {
      setValue((previousValue) => {
        const newValue = previousValue + 1;
        newValue >= 100 && clearInterval(updateProgress);
        return newValue;
      });
    }, onePercent);
  });

  return (
    <>
      {visible && (
        <Stack spacing={0} className={classes.container} bottom="0">
          <RingProgress
            size={90}
            thickness={7}
            sections={[{ value: 0, color: theme.primaryColor }]}
            onAnimationEnd={progressComplete}
            className={classes.progress}
            label={<Text className={classes.value}>{value}%</Text>}
          />
          {label && <Text className={classes.label}>{label}</Text>}
        </Stack>
      )}
    </>
  );
};

export default CircleProgressbar;

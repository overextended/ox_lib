import { useCallback, useEffect, useRef, useState } from 'react';
import { Box, createStyles, keyframes, Text } from '@mantine/core';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { fetchNui } from '../../utils/fetchNui';
import ScaleFade from '../../transitions/ScaleFade';
import type { MashGameData } from '../../typings';

const shake = keyframes({
  '0%, 100%': { transform: 'translateX(0)' },
  '20%, 60%': { transform: 'translateX(-6px)' },
  '40%, 80%': { transform: 'translateX(6px)' },
});

const useStyles = createStyles((theme, params: { isPressed: boolean; status: 'idle' | 'success' | 'fail' }) => ({
  wrapper: {
    width: '100%',
    height: '20%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    bottom: 0,
    position: 'absolute',
    userSelect: 'none',
    pointerEvents: 'none',
  },
  container: {
    width: 350,
    height: 45,
    borderRadius: theme.radius.sm,
    backgroundColor: theme.colors.dark[5],
    overflow: 'hidden',
    position: 'relative',
    boxShadow: theme.shadows.md,
    animation: params.status === 'fail' ? `${shake} 0.35s ease-in-out` : 'none',
    '@media (min-height: 1440px)': {
      width: 420,
      height: 52,
    },
  },
  bar: {
    height: '100%',
    backgroundColor:
      params.status === 'fail'
        ? theme.colors.red[6]
        : params.status === 'success'
        ? theme.colors.teal[5]
        : theme.colors[theme.primaryColor][theme.fn.primaryShade()],
    transition: 'background-color 0.15s ease',
  },
  labelWrapper: {
    position: 'absolute',
    top: 0,
    left: 0,
    display: 'flex',
    width: '100%',
    height: '100%',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 10,
    padding: '0 12px',
  },
  button: {
    backgroundColor: theme.colors.dark[6],
    width: 25,
    height: 25,
    textAlign: 'center',
    borderRadius: 5,
    fontSize: 16,
    fontWeight: 500,
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    color: theme.colors.gray[2],
    border: `1px solid ${
      params.status === 'fail'
        ? theme.colors.red[5]
        : params.status === 'success'
        ? theme.colors.teal[5]
        : params.isPressed
        ? theme.fn.primaryColor()
        : theme.colors.dark[4]
    }`,
    boxShadow: params.isPressed ? `0 0 8px ${theme.fn.primaryColor()}` : undefined,
    transform: params.isPressed ? 'scale(0.92)' : 'none',
    transition: 'transform 0.08s ease, border-color 0.1s ease, box-shadow 0.1s ease',
    '@media (min-height: 1440px)': {
      width: 30,
      height: 30,
      fontSize: 22,
    },
  },
  label: {
    width: 50,
    textAlign: 'left',
    fontVariantNumeric: 'tabular-nums',
    fontSize: 18,
    fontWeight: 500,
    color: theme.colors.gray[3],
    textShadow: theme.shadows.sm,
    fontFamily: 'Roboto Mono, monospace',
    '@media (min-height: 1440px)': {
      width: 60,
      fontSize: 22,
    },
  },
}));

const getNormalizedKey = (e: KeyboardEvent): string => {
  const isNonLatin = e.key.charCodeAt(0) >= 880;
  let convKey = e.key.toLowerCase();
  if (isNonLatin) {
    if (e.code.indexOf('Key') === 0 && e.code.length === 4) {
      convKey = e.code.charAt(3).toLowerCase();
    } else if (e.code.indexOf('Digit') === 0 && e.code.length === 6) {
      convKey = e.code.charAt(5).toLowerCase();
    }
  }
  return convKey;
};

const getRandomKey = (keys: string[], exclude?: string): string => {
  if (keys.length === 0) return 'e';
  if (keys.length === 1) return keys[0].toLowerCase();

  const filtered = keys.filter((k) => k.toLowerCase() !== exclude?.toLowerCase());
  const pool = filtered.length > 0 ? filtered : keys;
  return pool[Math.floor(Math.random() * pool.length)].toLowerCase();
};

const MashGame: React.FC = () => {
  const [visible, setVisible] = useState(false);
  const [targetKey, setTargetKey] = useState('e');
  const [progress, setProgress] = useState(0);
  const [isPressed, setIsPressed] = useState(false);
  const [status, setStatus] = useState<'idle' | 'success' | 'fail'>('idle');
  const [stageIndex, setStageIndex] = useState(0);
  const [totalStages, setTotalStages] = useState(1);

  const { classes } = useStyles({ isPressed, status });

  const gameDataRef = useRef<MashGameData | null>(null);
  const durationsRef = useRef<number[]>([]);
  const keysRef = useRef<string[]>(['e']);
  const stageIndexRef = useRef(0);
  const progressRef = useRef(0);
  const isPressedRef = useRef(false);
  const isCompletedRef = useRef(false);
  const isTransitioningRef = useRef(false);
  const previousKeyRef = useRef<string | null>(null);
  const activeKeysRef = useRef<Set<string>>(new Set());
  const gracePeriodUntilRef = useRef(0);
  const targetKeyRef = useRef('e');
  const lastTimeRef = useRef<number | null>(null);
  const rafIdRef = useRef<number | null>(null);
  const decayRateRef = useRef(25);
  const failOnWrongRef = useRef(true);
  const stageStartTimeRef = useRef(0);

  const loopRef = useRef<(time: number) => void>(() => {});

  const stopGameLoop = () => {
    if (rafIdRef.current !== null) {
      cancelAnimationFrame(rafIdRef.current);
      rafIdRef.current = null;
    }
    lastTimeRef.current = null;
  };

  const finishGame = (success: boolean) => {
    if (isCompletedRef.current) return;
    isCompletedRef.current = true;
    isTransitioningRef.current = false;
    activeKeysRef.current.clear();
    stopGameLoop();
    setStatus(success ? 'success' : 'fail');

    setTimeout(() => {
      setVisible(false);
      setStatus('idle');
      fetchNui('mashGameOver', success);
    }, success ? 250 : 400);
  };

  const advanceStage = () => {
    const nextIndex = stageIndexRef.current + 1;
    if (nextIndex >= durationsRef.current.length) {
      finishGame(true);
      return;
    }

    stopGameLoop();

    isTransitioningRef.current = true;
    previousKeyRef.current = targetKeyRef.current;
    isPressedRef.current = false;
    setIsPressed(false);
    setStatus('success');
    setProgress(100);

    setTimeout(() => {
      if (isCompletedRef.current) return;

      stageIndexRef.current = nextIndex;
      setStageIndex(nextIndex);

      const nextKey = getRandomKey(keysRef.current, previousKeyRef.current || undefined);
      targetKeyRef.current = nextKey;
      setTargetKey(nextKey);

      progressRef.current = 0;
      setProgress(0);
      setStatus('idle');

      const isAlreadyHeld = activeKeysRef.current.has(nextKey);
      isPressedRef.current = isAlreadyHeld;
      setIsPressed(isAlreadyHeld);

      stageStartTimeRef.current = performance.now();
      lastTimeRef.current = null;
      gracePeriodUntilRef.current = performance.now() + 400;
      isTransitioningRef.current = false;

      rafIdRef.current = requestAnimationFrame((time) => loopRef.current(time));
    }, 500);
  };

  const loop = useCallback((currentTime: number) => {
    if (isCompletedRef.current) return;

    if (lastTimeRef.current === null) {
      lastTimeRef.current = currentTime;
    }

    const delta = currentTime - lastTimeRef.current;
    lastTimeRef.current = currentTime;

    if (isTransitioningRef.current) {
      rafIdRef.current = requestAnimationFrame((time) => loopRef.current(time));
      return;
    }

    const currentDuration = durationsRef.current[stageIndexRef.current] || 3000;
    const decay = decayRateRef.current;

    const timeoutSetting = gameDataRef.current?.timeout;
    if (timeoutSetting) {
      const currentTimeout = Array.isArray(timeoutSetting)
        ? timeoutSetting[stageIndexRef.current] || timeoutSetting[0]
        : timeoutSetting;
      if (currentTimeout && currentTime - stageStartTimeRef.current > currentTimeout) {
        finishGame(false);
        return;
      }
    }

    const isTargetHeld = activeKeysRef.current.has(targetKeyRef.current);
    if (isPressedRef.current !== isTargetHeld) {
      isPressedRef.current = isTargetHeld;
      setIsPressed(isTargetHeld);
    }

    if (isPressedRef.current) {
      const increment = (delta / currentDuration) * 100;
      progressRef.current = Math.min(100, progressRef.current + increment);
    } else {
      const decrement = (delta / 1000) * decay;
      progressRef.current = Math.max(0, progressRef.current - decrement);
    }

    setProgress(progressRef.current);

    if (progressRef.current >= 100) {
      advanceStage();
      return;
    }

    rafIdRef.current = requestAnimationFrame((time) => loopRef.current(time));
  }, []);

  useEffect(() => {
    loopRef.current = loop;
  }, [loop]);

  const handleKeyDown = useCallback((e: KeyboardEvent) => {
    if (isCompletedRef.current) return;

    if (e.key === 'Escape') {
      finishGame(false);
      return;
    }

    if (['Shift', 'Control', 'Alt', 'Meta', 'Tab', 'CapsLock'].includes(e.key)) {
      return;
    }

    const pressedKey = getNormalizedKey(e);
    activeKeysRef.current.add(pressedKey);

    if (pressedKey === targetKeyRef.current) {
      previousKeyRef.current = null;
      if (!isPressedRef.current) {
        isPressedRef.current = true;
        setIsPressed(true);
      }
      return;
    }

    // Ignore previous stage key until released to prevent false failure.
    if (previousKeyRef.current && pressedKey === previousKeyRef.current) {
      return;
    }

    if (isTransitioningRef.current || performance.now() < gracePeriodUntilRef.current) {
      return;
    }

    // Suppress OS key repeat events for wrong keys.
    if (e.repeat) {
      return;
    }

    if (failOnWrongRef.current) {
      activeKeysRef.current.clear();
      isPressedRef.current = false;
      setIsPressed(false);
      finishGame(false);
    }
  }, []);

  const handleKeyUp = useCallback((e: KeyboardEvent) => {
    if (isCompletedRef.current) return;

    const releasedKey = getNormalizedKey(e);
    activeKeysRef.current.delete(releasedKey);

    if (previousKeyRef.current && releasedKey === previousKeyRef.current) {
      previousKeyRef.current = null;
    }

    if (releasedKey === targetKeyRef.current) {
      isPressedRef.current = false;
      setIsPressed(false);
    }
  }, []);

  const handleBlur = useCallback(() => {
    activeKeysRef.current.clear();
    isPressedRef.current = false;
    setIsPressed(false);
    previousKeyRef.current = null;
  }, []);

  useNuiEvent<MashGameData>('startMashGame', (data) => {
    gameDataRef.current = data;

    const durations = Array.isArray(data.durations) ? data.durations : [data.durations || 3000];
    const keys = data.keys && data.keys.length > 0 ? data.keys : ['e'];

    durationsRef.current = durations;
    keysRef.current = keys;
    decayRateRef.current = typeof data.decayRate === 'number' ? data.decayRate : 25;
    failOnWrongRef.current = data.failOnWrongKey !== false;

    stageIndexRef.current = 0;
    progressRef.current = 0;
    isPressedRef.current = false;
    isCompletedRef.current = false;
    isTransitioningRef.current = false;
    previousKeyRef.current = null;
    activeKeysRef.current.clear();
    gracePeriodUntilRef.current = 0;

    const firstKey = getRandomKey(keys);
    targetKeyRef.current = firstKey;

    setTargetKey(firstKey);
    setProgress(0);
    setIsPressed(false);
    setStatus('idle');
    setStageIndex(0);
    setTotalStages(durations.length);
    setVisible(true);

    stageStartTimeRef.current = performance.now();
    lastTimeRef.current = null;
    rafIdRef.current = requestAnimationFrame((time) => loopRef.current(time));
  });

  useNuiEvent('mashGameCancel', () => {
    finishGame(false);
  });

  useEffect(() => {
    if (!visible) return;

    window.addEventListener('keydown', handleKeyDown);
    window.addEventListener('keyup', handleKeyUp);
    window.addEventListener('blur', handleBlur);

    return () => {
      window.removeEventListener('keydown', handleKeyDown);
      window.removeEventListener('keyup', handleKeyUp);
      window.removeEventListener('blur', handleBlur);
      stopGameLoop();
    };
  }, [visible, handleKeyDown, handleKeyUp, handleBlur]);

  if (!visible) return null;

  return (
    <Box className={classes.wrapper}>
      <ScaleFade visible={visible}>
        <Box className={classes.container}>
          <Box
            className={classes.bar}
            sx={{ width: `${Math.min(100, Math.max(0, progress))}%` }}
          />
          <Box className={classes.labelWrapper}>
            <Box className={classes.button}>{targetKey.toUpperCase()}</Box>
            <Text className={classes.label}>{Math.floor(progress)}%</Text>
          </Box>
        </Box>
      </ScaleFade>
    </Box>
  );
};

export default MashGame;

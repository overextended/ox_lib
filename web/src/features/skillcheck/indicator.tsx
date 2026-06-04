import { useCallback, useEffect, useRef, useState } from 'react';
import type { SkillCheckProps } from '../../typings';

interface Props {
  angle: number;
  offset: number;
  multiplier: number;
  skillCheck: SkillCheckProps;
  className: string;
  handleComplete: (success: boolean) => void;
}

const BASE_DURATION_MS = 2000;

const Indicator: React.FC<Props> = ({
  angle,
  offset,
  multiplier,
  handleComplete,
  skillCheck,
  className,
}) => {
  const [indicatorAngle, setIndicatorAngle] = useState(-90);
  const [keyPressed, setKeyPressed] = useState<false | string>(false);

  const rafIdRef = useRef<number | null>(null);
  const startTimeRef = useRef<number | null>(null);
  const completedRef = useRef(false);

  const stopAnimation = () => {
    if (rafIdRef.current !== null) {
      cancelAnimationFrame(rafIdRef.current);
      rafIdRef.current = null;
    }
  };

  const animate = useCallback(
    (time: number) => {
      if (completedRef.current) return;

      if (startTimeRef.current === null) {
        startTimeRef.current = time;
      }

      const elapsed = time - startTimeRef.current;

      const speed = Math.max(multiplier || 0, 0.0001);
      const duration = BASE_DURATION_MS / speed;

      const progress = Math.min(elapsed / duration, 1);
      const newAngle = -90 + progress * 360;

      setIndicatorAngle(newAngle);

      if (newAngle + 90 >= 360) {
        completedRef.current = true;
        stopAnimation();
        handleComplete(false);
        return;
      }

      rafIdRef.current = requestAnimationFrame(animate);
    },
    [multiplier, handleComplete]
  );
  const keyHandler = useCallback(
    (e: KeyboardEvent) => {
      const capitalHetaCode = 880;
      const isNonLatin = e.key.charCodeAt(0) >= capitalHetaCode;
      var convKey = e.key.toLowerCase()
      if (isNonLatin) {
        if (e.code.indexOf('Key') === 0 && e.code.length === 4) { // i.e. 'KeyW'
          convKey = e.code.charAt(3);
        }

        if (e.code.indexOf('Digit') === 0 && e.code.length === 6) { // i.e. 'Digit7'
          convKey = e.code.charAt(5);
        }
      }
      setKeyPressed(convKey.toLowerCase());
    },
    [skillCheck]
  );

  useEffect(() => {
    setIndicatorAngle(-90);
    startTimeRef.current = null;
    completedRef.current = false;

    window.addEventListener('keydown', keyHandler);
    rafIdRef.current = requestAnimationFrame(animate);

    return () => {
      stopAnimation();
      window.removeEventListener('keydown', keyHandler);
      startTimeRef.current = null;
      completedRef.current = true;
    };
  }, [skillCheck, keyHandler, animate]);

  useEffect(() => {
    if (!keyPressed || completedRef.current) return;

    if (skillCheck.keys && !skillCheck.keys?.includes(keyPressed)) return;

    stopAnimation();
    window.removeEventListener('keydown', keyHandler);
    completedRef.current = true;

    if (keyPressed !== skillCheck.key || indicatorAngle < angle || indicatorAngle > angle + offset)
      handleComplete(false);
    else handleComplete(true);

    setKeyPressed(false);
  }, [
    keyPressed,
    angle,
    offset,
    indicatorAngle,
    skillCheck,
    keyHandler,
    handleComplete,
  ]);

  return <circle transform={`rotate(${indicatorAngle}, 250, 250)`} className={className} />;
};

export default Indicator;

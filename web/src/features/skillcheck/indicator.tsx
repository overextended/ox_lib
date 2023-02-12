import { useCallback, useEffect, useState } from 'react';
import { useKeyPress } from '../../hooks/useKeyPress';
import { SkillCheckProps } from './index';
import { useInterval } from '@mantine/hooks';
import { circleCircumference } from './index';

interface Props {
  angle: number;
  offset: number;
  multiplier: number;
  skillCheck: SkillCheckProps;
  className: string;
  handleComplete: (success: boolean) => void;
}

const Indicator: React.FC<Props> = ({ angle, offset, multiplier, handleComplete, skillCheck, className }) => {
  const [indicatorAngle, setIndicatorAngle] = useState(-90);
  const [keyPressed, setKeyPressed] = useState(false);
  const interval = useInterval(
    () =>
      setIndicatorAngle((prevState) => {
        return (prevState += multiplier);
      }),
    1
  );

  const keyHandler = useCallback(
    (e: KeyboardEvent) => {
      if (e.key.toLowerCase() !== skillCheck.key.toLowerCase()) return;
      setKeyPressed(true);
    },
    [skillCheck]
  );

  useEffect(() => {
    setIndicatorAngle(-90);
    window.addEventListener('keydown', keyHandler);
    interval.start();
  }, [skillCheck]);

  useEffect(() => {
    if (indicatorAngle + 90 >= 360) {
      interval.stop();
      handleComplete(false);
    }
  }, [indicatorAngle]);

  useEffect(() => {
    if (!keyPressed) return;

    interval.stop();

    setKeyPressed(false);
    window.removeEventListener('keydown', keyHandler);

    if (indicatorAngle < angle || indicatorAngle > angle + offset) handleComplete(false);
    else handleComplete(true);
  }, [keyPressed]);

  return (
    <circle
      r={50}
      cx={250}
      cy={250}
      strokeDasharray={circleCircumference}
      strokeDashoffset={circleCircumference - 3}
      transform={`rotate(${indicatorAngle}, 250, 250)`}
      className={className}
    />
  );
};

export default Indicator;

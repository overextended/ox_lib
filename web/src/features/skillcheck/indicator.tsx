import { useCallback, useEffect, useState } from 'react';
import type { SkillCheckProps } from '../../typings';
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
  const [keyPressed, setKeyPressed] = useState<false | string>(false);
  const interval = useInterval(
    () =>
      setIndicatorAngle((prevState) => {
        return (prevState += multiplier);
      }),
    1
  );

  const keyHandler = useCallback(
    (e: KeyboardEvent) => {
      setKeyPressed(e.key.toLowerCase());
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

    window.removeEventListener('keydown', keyHandler);

    if (keyPressed !== skillCheck.key.toLowerCase() || indicatorAngle < angle || indicatorAngle > angle + offset)
      handleComplete(false);
    else handleComplete(true);

    setKeyPressed(false);
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

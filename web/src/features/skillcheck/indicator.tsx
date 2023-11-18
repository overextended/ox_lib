import { useCallback, useEffect, useState } from 'react';
import type { SkillCheckProps } from '../../typings';
import { useInterval } from '@mantine/hooks';

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

    if (skillCheck.keys && !skillCheck.keys?.includes(keyPressed)) return;

    interval.stop();

    window.removeEventListener('keydown', keyHandler);

    if (keyPressed !== skillCheck.key || indicatorAngle < angle || indicatorAngle > angle + offset)
      handleComplete(false);
    else handleComplete(true);

    setKeyPressed(false);
  }, [keyPressed]);

  return <circle transform={`rotate(${indicatorAngle}, 250, 250)`} className={className} />;
};

export default Indicator;

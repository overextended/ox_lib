import { useEffect, useRef, useState } from 'react';
import { useKeyPress } from '../../hooks/useKeyPress';
import { SkillCheckProps } from './index';
// import { useInterval } from '@chakra-ui/react';
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
  const isKeyPressed = useKeyPress('e');
  const interval = useInterval(
    () =>
      setIndicatorAngle((prevState) => {
        return (prevState += multiplier);
      }),
    1
  );

  useEffect(() => {
    setIndicatorAngle(-90);
    interval.start();
  }, [skillCheck]);

  useEffect(() => {
    if (indicatorAngle + 90 >= 360) {
      interval.stop();
      handleComplete(false);
    }
  }, [indicatorAngle]);

  useEffect(() => {
    if (!isKeyPressed) return;

    interval.stop();

    if (indicatorAngle < angle || indicatorAngle > angle + offset) handleComplete(false);
    else handleComplete(true);
  }, [isKeyPressed]);

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

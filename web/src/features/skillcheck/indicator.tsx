import { useEffect, useRef, useState } from 'react';
import { useKeyPress } from '../../hooks/useKeyPress';
import { SkillCheckProps } from './index';
import { useInterval } from '@chakra-ui/react';
import { circleCircumference } from './index';

interface Props {
  angle: number;
  offset: number;
  multiplier: number;
  skillCheck: SkillCheckProps;
  handleComplete: (success: boolean) => void;
}

const Indicator: React.FC<Props> = ({ angle, offset, multiplier, handleComplete, skillCheck }) => {
  const [indicatorAngle, setIndicatorAngle] = useState(-90);
  const [gameState, setGameState] = useState(false);
  const isKeyPressed = useKeyPress('e');

  useInterval(
    () => {
      setIndicatorAngle((prevState) => {
        return (prevState += multiplier);
      });
    },
    gameState ? 1 : null
  );

  useEffect(() => {
    setIndicatorAngle(-90);
    setGameState(true);
  }, [skillCheck]);

  useEffect(() => {
    if (indicatorAngle + 90 >= 360) {
      setGameState(false);
      handleComplete(false);
    }
  }, [indicatorAngle]);

  useEffect(() => {
    if (!isKeyPressed) return;

    setGameState(false);

    if (indicatorAngle < angle || indicatorAngle > angle + offset) handleComplete(false);
    else handleComplete(true);
  }, [isKeyPressed]);

  return (
    <circle
      r={50}
      cx={250}
      cy={250}
      fill="transparent"
      stroke="red"
      strokeWidth={15}
      strokeDasharray={circleCircumference}
      strokeDashoffset={circleCircumference - 3}
      transform={`rotate(${indicatorAngle}, 250, 250)`}
    />
  );
};

export default Indicator;

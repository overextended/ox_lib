import { useEffect, useRef, useState } from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { useKeyPress } from '../../hooks/useKeyPress';
import { fetchNui } from '../../utils/fetchNui';
import skillcheck, { SkillCheckProps } from './index';
import { useInterval } from '@chakra-ui/react';
import { Simulate } from 'react-dom/test-utils';
import keyPress = Simulate.keyPress;

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
      // fetchNui('skillCheckOver', { success: false });
      setGameState(false);
      handleComplete(false);
    }
  }, [indicatorAngle]);

  useEffect(() => {
    if (!isKeyPressed) return;
    //

    setGameState(false);
    if (isKeyPressed) {
      if (indicatorAngle < angle || indicatorAngle > angle + (315 - offset)) {
        // fetchNui('skillCheckOver', { success: false });
        handleComplete(false);
      } else {
        // fetchNui('skillCheckOver', { success: true });
        handleComplete(true);
      }
    }
  }, [isKeyPressed]);

  return (
    <circle
      r={50}
      cx={250}
      cy={250}
      fill="transparent"
      stroke="red"
      strokeWidth={15}
      strokeDasharray={315}
      strokeDashoffset={312}
      transform={`rotate(${indicatorAngle}, 250, 250)`}
    />
  );
};

export default Indicator;

import { useEffect, useRef, useState } from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { useKeyPress } from '../../hooks/useKeyPress';
import { fetchNui } from '../../utils/fetchNui';
import { SkillCheckProps } from './index';

interface Props {
  angle: number;
  offset: number;
  multiplier: number;
  setSkillCheck: React.Dispatch<React.SetStateAction<SkillCheckProps>>;
}

const Indicator: React.FC<Props> = ({ angle, offset, multiplier, setSkillCheck }) => {
  const [indicatorAngle, setIndicatorAngle] = useState(-90);
  const intervalRef = useRef<NodeJS.Timer | null>(null);
  const isKeyPressed = useKeyPress('e');

  useEffect(() => {
    intervalRef.current = setInterval(() => {
      setIndicatorAngle((prevState) => (prevState += multiplier));
    }, 1);

    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current);
    };
  }, []);

  useEffect(() => {
    if (intervalRef.current && indicatorAngle + 90 >= 360) {
      clearInterval(intervalRef.current);
      fetchNui('skillCheckOver', { success: false });
      setSkillCheck((prevState) => ({ ...prevState, visible: false }));
    }

    if (isKeyPressed && intervalRef.current) {
      clearInterval(intervalRef.current);
      if (indicatorAngle < angle || indicatorAngle > angle + (315 - offset)) {
        fetchNui('skillCheckOver', { success: false });
      } else {
        fetchNui('skillCheckOver', { success: true });
      }
      setSkillCheck((prevState) => ({ ...prevState, visible: false }));
    }
  }, [indicatorAngle, isKeyPressed]);

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

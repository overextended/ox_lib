import { useRef, useState } from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import Indicator from './indicator';
import { fetchNui } from '../../utils/fetchNui';
import { useMantineTheme, Box, createStyles } from '@mantine/core';

interface CustomGameDifficulty {
  areaSize: number;
  speedMultiplier: number;
}

export type GameDifficulty = 'easy' | 'medium' | 'hard' | CustomGameDifficulty;

export interface SkillCheckProps {
  angle: number;
  difficultyOffset: number;
  difficulty: GameDifficulty;
  key: string;
}

export const circleCircumference = 2 * 50 * Math.PI;

const getRandomAngle = (min: number, max: number) => Math.floor(Math.random() * (max - min)) + min;

const difficultyOffsets = {
  easy: 50,
  medium: 40,
  hard: 25,
};

const useStyles = createStyles((theme) => ({
  svg: {
    position: 'absolute',
    top: '50%',
    left: '50%',
    transform: 'translate(-50%, -50%)',
  },
  track: {
    fill: 'transparent',
    stroke: theme.colors.dark[5],
    strokeWidth: 8,
  },
  skillArea: {
    fill: 'transparent',
    stroke: theme.fn.primaryColor(),
    strokeWidth: 8,
  },
  indicator: {
    stroke: 'red',
    strokeWidth: 16,
    fill: 'transparent',
  },
  button: {
    position: 'absolute',
    left: '50%',
    top: '50%',
    transform: 'translate(-50%, -50%)',
    backgroundColor: theme.colors.dark[5],
    width: 25,
    height: 25,
    textAlign: 'center',
    borderRadius: 5,
    fontSize: 16,
    fontWeight: 500,
  },
}));

const SkillCheck: React.FC = () => {
  const { classes } = useStyles();
  const [visible, setVisible] = useState(false);
  const dataRef = useRef<{ difficulty: GameDifficulty | GameDifficulty[]; inputs?: string[] } | null>(null);
  const dataIndexRef = useRef<number>(0);
  const [skillCheck, setSkillCheck] = useState<SkillCheckProps>({
    angle: 0,
    difficultyOffset: 50,
    difficulty: 'easy',
    key: 'e',
  });

  useNuiEvent('startSkillCheck', (data: { difficulty: GameDifficulty | GameDifficulty[]; inputs?: string[] }) => {
    dataRef.current = data;
    dataIndexRef.current = 0;
    const gameData = Array.isArray(data.difficulty) ? data.difficulty[0] : data.difficulty;
    const offset = typeof gameData === 'object' ? gameData.areaSize : difficultyOffsets[gameData];
    const randomKey = data.inputs ? data.inputs[Math.floor(Math.random() * data.inputs.length)] : 'e';
    setSkillCheck({
      angle: -90 + getRandomAngle(120, 360 - offset),
      difficultyOffset: offset,
      difficulty: gameData,
      key: randomKey,
    });

    setVisible(true);
  });

  const handleComplete = (success: boolean) => {
    if (!dataRef.current) return;
    if (!success || !Array.isArray(dataRef.current.difficulty)) {
      setVisible(false);
      return fetchNui('skillCheckOver', success);
    }

    if (dataIndexRef.current >= dataRef.current.difficulty.length - 1) {
      setVisible(false);
      return fetchNui('skillCheckOver', success);
    }

    dataIndexRef.current++;
    const data = dataRef.current.difficulty[dataIndexRef.current];
    const key = dataRef.current.inputs
      ? dataRef.current.inputs[Math.floor(Math.random() * dataRef.current.inputs.length)]
      : 'e';
    const offset = typeof data === 'object' ? data.areaSize : difficultyOffsets[data];
    setSkillCheck({
      angle: -90 + getRandomAngle(120, 360 - offset),
      difficultyOffset: offset,
      difficulty: data,
      key,
    });
  };

  return (
    <>
      {visible && (
        <>
          <svg r={50} width={500} height={500} className={classes.svg}>
            {/*Circle track*/}
            <circle r={50} cx={250} cy={250} className={classes.track} strokeDasharray={circleCircumference} />
            {/*SkillCheck area*/}
            <circle
              r={50}
              cx={250}
              cy={250}
              strokeDasharray={circleCircumference}
              strokeDashoffset={circleCircumference - (Math.PI * 50 * skillCheck.difficultyOffset) / 180}
              transform={`rotate(${skillCheck.angle}, 250, 250)`}
              className={classes.skillArea}
            />
            <Indicator
              angle={skillCheck.angle}
              offset={skillCheck.difficultyOffset}
              multiplier={
                skillCheck.difficulty === 'easy'
                  ? 1
                  : skillCheck.difficulty === 'medium'
                  ? 1.5
                  : skillCheck.difficulty === 'hard'
                  ? 1.75
                  : skillCheck.difficulty.speedMultiplier
              }
              handleComplete={handleComplete}
              className={classes.indicator}
              skillCheck={skillCheck}
            />
          </svg>
          <Box className={classes.button}>{skillCheck.key.toUpperCase()}</Box>
        </>
      )}
    </>
  );
};

export default SkillCheck;

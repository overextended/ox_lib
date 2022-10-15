import { Box, Center } from '@chakra-ui/react';
import { useEffect, useMemo, useState } from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { debugData } from '../../utils/debugData';
import Indicator from './indicator';

interface CustomGameDifficulty {
  areaSize: number;
  speedMultiplier: number;
}

type GameDifficulty = 'easy' | 'medium' | 'hard' | CustomGameDifficulty;

export interface SkillCheckProps {
  visible: boolean;
  angle: number;
  difficultyOffset: number;
  difficulty: GameDifficulty;
}

const getRandomAngle = (min: number, max: number) => Math.floor(Math.random() * (max - min)) + min;

const difficultyOffsets = {
  easy: 275,
  medium: 290,
  hard: 295,
};

debugData([
  {
    action: 'startSkillCheck',
    data: 'easy',
  },
]);

const SkillCheck: React.FC = () => {
  const [skillCheck, setSkillCheck] = useState<SkillCheckProps>({
    visible: false,
    angle: 0,
    difficultyOffset: 315,
    difficulty: 'easy',
  });

  useNuiEvent('startSkillCheck', (data: GameDifficulty) => {
    const offset = typeof data === 'object' ? data.areaSize : difficultyOffsets[data];
    setSkillCheck({
      visible: true,
      angle: -90 + getRandomAngle(120, 360 - (315 - offset)),
      difficultyOffset: offset,
      difficulty: data,
    });
  });

  return (
    <Center height="100%" width="100%">
      {skillCheck.visible && (
        <>
          <svg width={500} height={500}>
            {/*Circle track*/}
            <circle
              r={50}
              cx={250}
              cy={250}
              fill="transparent"
              stroke="rgba(0, 0, 0, 0.4)"
              strokeWidth={5}
              strokeDasharray={360}
            />
            {/*SkillCheck area*/}
            <circle
              r={50}
              cx={250}
              cy={250}
              fill="transparent"
              stroke="white"
              strokeDasharray={315}
              strokeDashoffset={skillCheck.difficultyOffset}
              strokeWidth={5}
              transform={`rotate(${skillCheck.angle}, 250, 250)`}
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
              setSkillCheck={setSkillCheck}
            />
          </svg>
          <Box
            position="absolute"
            left="50%"
            top="50%"
            transform="translate(-50%, -50%)"
            backgroundColor="rgba(0, 0, 0, 0.4)"
            w={25}
            h={25}
            textAlign="center"
            borderRadius={5}
            fontFamily="Inter"
            fontSize={16}
          >
            E
          </Box>
        </>
      )}
    </Center>
  );
};

export default SkillCheck;

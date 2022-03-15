import React from "react";
import {
  CircularProgress,
  CircularProgressLabel,
  Flex,
  ScaleFade,
} from "@chakra-ui/react";
import { useNuiEvent } from "../hooks/useNuiEvent";
import { debugData } from "../utils/debugData";
import { fetchNui } from "../utils/fetchNui";

interface Props {
  duration: number;
}

// debugData([
//   {
//     action: "circleProgress",
//     data: {
//       duration: 8000,
//     },
//   },
// ]);

const CircleProgressbar: React.FC = () => {
  const [visible, setVisible] = React.useState(false);
  const [progressDuration, setProgressDuration] = React.useState(0);
  const [value, setValue] = React.useState(0);

  const progressComplete = () => {
    setVisible(false);
    fetchNui("progressComplete");
  };

  useNuiEvent<Props>("circleProgress", (data) => {
    if (visible) return;
    setVisible(true);
    setValue(0);
    setProgressDuration(data.duration);
    const onePercent = data.duration * 0.01;
    const updateProgress = setInterval(() => {
      setValue((previousValue) => {
        const newValue = previousValue + 1;
        newValue >= 100 && clearInterval(updateProgress);
        return newValue;
      });
    }, onePercent);
  });

  return (
    <Flex
      h="20%"
      w="100%"
      position="absolute"
      bottom="0"
      justifyContent="center"
      alignItems="center"
    >
      <ScaleFade in={visible} unmountOnExit>
        <CircularProgress
          value={value}
          size="7rem"
          onAnimationEnd={progressComplete}
          sx={{
            ".chakra-progress__indicator": {
              transition: "none !important",
              animation: "progress linear forwards !important",
              animationDuration: `${progressDuration}ms !important`,
              opacity: "1 !important",
            },
          }}
        >
          <CircularProgressLabel color="black">{value}%</CircularProgressLabel>
        </CircularProgress>
      </ScaleFade>
    </Flex>
  );
};

export default CircleProgressbar;

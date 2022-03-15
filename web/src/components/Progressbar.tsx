import React from "react";
import {
  Progress,
  ProgressLabel,
  Flex,
  Box,
  ScaleFade,
} from "@chakra-ui/react";
import { useNuiEvent } from "../hooks/useNuiEvent";
import { debugData } from "../utils/debugData";
import { fetchNui } from "../utils/fetchNui";

interface Props {
  label: string;
  duration: number;
}

debugData([
  {
    action: "progress",
    data: {
      label: "Using lockpick",
      duration: 8000,
    },
  },
]);

const Progressbar: React.FC = () => {
  const [visible, setVisible] = React.useState(false);
  const [label, setLabel] = React.useState("");
  const [duration, setDuration] = React.useState(0);

  const progressComplete = () => {
    setVisible(false);
    fetchNui("progressComplete");
  };

  useNuiEvent<Props>("progress", (data) => {
    if (visible) return;
    setVisible(true);
    setLabel(data.label);
    setDuration(data.duration);
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
      <Box width="22rem">
        <ScaleFade in={visible} unmountOnExit>
          <Progress
            value={100}
            backgroundColor="rgba(0, 0, 0, 0.6)"
            height="3rem"
            flex="1 1 auto"
            onAnimationEnd={progressComplete}
            sx={{
              // really scuffed solution but works, wonder if there's a better way to do this?
              "> div:first-of-type": {
                animation: `progress-bar linear ${duration}ms`,
              },
            }}
          >
            <ProgressLabel fontSize={22}>{label}</ProgressLabel>
          </Progress>
        </ScaleFade>
      </Box>
    </Flex>
  );
};

export default Progressbar;

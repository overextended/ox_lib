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
      label: "Using Lockpick",
      duration: 8000,
    },
  },
]);

const Progressbar: React.FC = () => {
  const [visible, setVisible] = React.useState(false);
  const [label, setLabel] = React.useState("");
  const [duration, setDuration] = React.useState(0);
  const [cancelled, setCancelled] = React.useState(false);

  const progressComplete = () => {
    setVisible(false);
    fetchNui("progressComplete");
  };

  const progressCancel = () => {
    setCancelled(true);
    setTimeout(() => {
      setVisible(false);
    }, 2500);
  };

  useNuiEvent("progressCancel", progressCancel);

  useNuiEvent<Props>("progress", (data) => {
    if (visible) return;
    setCancelled(false);
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
            height="2.8rem"
            borderRadius="sm"
            fontFamily="Inter"
            flex="1 1 auto"
            boxShadow="lg"
            onAnimationEnd={progressComplete}
            sx={
              !cancelled
                ? {
                    // really scuffed solution but works, wonder if there's a better way to do this?
                    "> div:first-of-type": {
                      animation: `progress-bar linear ${duration}ms`,
                      borderRadius: "none",
                    },
                  }
                : {
                    "> div:first-of-type": {
                      width: "100%",
                      backgroundColor: "rgb(198, 40, 40)",
                    },
                  }
            }
          >
            <ProgressLabel fontSize={22} fontWeight="light">
              {label}
            </ProgressLabel>
          </Progress>
        </ScaleFade>
      </Box>
    </Flex>
  );
};

export default Progressbar;

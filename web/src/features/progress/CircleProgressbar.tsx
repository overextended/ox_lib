import React from "react";
import {
  CircularProgress,
  CircularProgressLabel,
  Flex,
  Text,
} from "@chakra-ui/react";
import { useNuiEvent } from "../../hooks/useNuiEvent";
import { debugData } from "../../utils/debugData";
import { fetchNui } from "../../utils/fetchNui";

interface Props {
  label?: string;
  duration: number;
  position?: "middle" | "bottom";
  percent?: boolean;
}

debugData([
  {
    action: "circleProgress",
    data: {
      duration: 8000,
      label: "Using Armour",
    },
  },
]);

const CircleProgressbar: React.FC = () => {
  const [visible, setVisible] = React.useState(false);
  const [progressDuration, setProgressDuration] = React.useState(0);
  const [position, setPosition] = React.useState<"middle" | "bottom">("middle");
  const [value, setValue] = React.useState(0);
  const [label, setLabel] = React.useState("");
  const [cancelled, setCancelled] = React.useState(false);

  const progressComplete = () => {
    setVisible(false);
    fetchNui("progressComplete");
  };

  const progressCancel = () => {
    setCancelled(true);
    setValue(99); // Sets the final value to 100% kek
    setVisible(false);
  };

  useNuiEvent("progressCancel", progressCancel);

  useNuiEvent<Props>("circleProgress", (data) => {
    if (visible) return;
    setCancelled(false);
    setVisible(true);
    setValue(0);
    setLabel(data.label || "");
    setProgressDuration(data.duration);
    setPosition(data.position || "middle");
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
      h={position === "middle" ? "100%" : "20%"}
      w="100%"
      position="absolute"
      bottom="0"
      justifyContent="center"
      alignItems="center"
    >
      {visible && (
        <Flex alignItems="center" flexDirection="column">
          <CircularProgress
            value={value}
            size="5rem"
            trackColor="rgba(0, 0, 0, 0.6)"
            onAnimationEnd={progressComplete}
            thickness={6}
            color={cancelled ? "rgb(198, 40, 40)" : "white"}
            sx={
              !cancelled
                ? {
                    ".chakra-progress__indicator": {
                      transition: "none !important",
                      animation: "progress linear forwards !important",
                      animationDuration: `${progressDuration}ms !important`,
                      opacity: "1 !important",
                    },
                  }
                : {
                    // Currently unused
                    ".chakra-progress__indicator": {
                      transition: "none !important",
                      strokeDasharray: "264, 0 !important", // sets circle to full
                    },
                  }
            }
          >
            <CircularProgressLabel fontFamily="Fira Mono">
              {value}%
            </CircularProgressLabel>
          </CircularProgress>
          <Text fontFamily="Inter" isTruncated fontSize={18} fontWeight="light">
            {label}
          </Text>
        </Flex>
      )}
    </Flex>
  );
};

export default CircleProgressbar;

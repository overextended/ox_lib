import React from "react";
import { Text, Flex, Box } from "@chakra-ui/react";
import { useNuiEvent } from "../../hooks/useNuiEvent";
import { debugData } from "../../utils/debugData";
import { fetchNui } from "../../utils/fetchNui";

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
    setVisible(false);
  };

  useNuiEvent("progressCancel", progressCancel);

  useNuiEvent<Props>("progress", (data) => {
    setCancelled(false);
    setVisible(true);
    setLabel(data.label);
    setDuration(data.duration);
  });

  return (
    <Flex
      h="30%"
      w="100%"
      position="absolute"
      bottom="0"
      justifyContent="center"
      alignItems="center"
    >
      <Box width={350}>
        {visible && (
          <Box
            height={45}
            bg="rgba(0, 0, 0, 0.6)"
            textAlign="center"
            borderRadius="sm"
            boxShadow="lg"
            overflow="hidden"
          >
            <Box
              height={45}
              onAnimationEnd={progressComplete}
              sx={
                !cancelled
                  ? {
                      width: "0%",
                      backgroundColor: "green.400",
                      animation: "progress-bar linear",
                      animationDuration: `${duration}ms`,
                    }
                  : {
                      // Currently unused
                      width: "100%",
                      animationPlayState: "paused",
                      backgroundColor: "rgb(198, 40, 40)",
                    }
              }
            />
            <Text
              fontFamily="Inter"
              isTruncated
              fontSize={22}
              fontWeight="light"
              position="absolute"
              top="50%"
              left="50%"
              transform="translate(-50%, -50%)"
            >
              {label}
            </Text>
          </Box>
        )}
      </Box>
    </Flex>
  );
};

export default Progressbar;

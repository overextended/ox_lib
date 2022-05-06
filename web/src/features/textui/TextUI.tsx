import React from "react";
import { useNuiEvent } from "../../hooks/useNuiEvent";
import { Box, Flex, ScaleFade } from "@chakra-ui/react";
import { debugData } from "../../utils/debugData";
import ReactMarkdown from "react-markdown";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { IconProp } from "@fortawesome/fontawesome-svg-core";

interface Props {
  text: string;
  position?: "right-center" | "left-center" | "top-center";
  icon?: IconProp;
  iconColor?: string;
  style?: React.CSSProperties;
}

debugData([
  {
    action: "textUi",
    data: {
      text: "[E] - Access locker inventory  \n [G] - Do something else",
      position: "right-center",
      icon: "door-open",
    },
  },
]);

const TextUI: React.FC = () => {
  const [data, setData] = React.useState<Props>({
    text: "",
    position: "right-center",
  });
  const [visible, setVisible] = React.useState(false);

  useNuiEvent<Props>("textUi", (data) => {
    if (!data.position) data.position = "right-center"; // Default right position
    setData(data);
    setVisible(true);
  });

  useNuiEvent("textUiHide", () => setVisible(false));

  return (
    <Flex
      w="100%"
      h="100%"
      p={3}
      position="absolute"
      alignItems={data.position === "top-center" ? "baseline" : "center"}
      justifyContent={
        data.position === "right-center"
          ? "flex-end"
          : data.position === "left-center"
          ? "flex-start"
          : "center"
      }
    >
      <ScaleFade in={visible} unmountOnExit>
        <Box
          bg="gray.700"
          boxShadow="md"
          p={3}
          fontFamily="Poppins"
          fontSize="0.95em"
          style={data.style}
          borderRadius="sm"
          maxW="xs"
        >
          <Flex justifyContent="center" alignItems="center">
            {data.icon && (
              <FontAwesomeIcon
                fixedWidth
                icon={data.icon}
                color={data.iconColor}
                fontSize="1.3em"
                style={{ paddingRight: 8 }}
              />
            )}
            <ReactMarkdown>{data.text}</ReactMarkdown>
          </Flex>
        </Box>
      </ScaleFade>
    </Flex>
  );
};

export default TextUI;

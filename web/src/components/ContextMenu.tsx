import { useNuiEvent } from "../hooks/useNuiEvent";
import { Box, Text } from "@chakra-ui/react";
import { debugData } from "../utils/debugData";
import { useState } from "react";

interface Props {
  title: string;
  options: Options;
}

interface Options {
  [key: string]: {
    description: string;
  };
}

debugData<Props>([
  {
    action: "showContext",
    data: {
      title: "Vehicle garage",
      options: {
        ["Dinka Blista"]: {
          description: "Plate: XDD 200",
        },
        ["Elegy Nitro"]: {
          description: "Plate: DKL 751",
        },
      },
    },
  },
]);

const ContextMenu: React.FC = () => {
  const [visible, setVisible] = useState(false);
  const [contextMenu, setContextMenu] = useState<Props>({
    title: "",
    options: { [""]: { description: "" } },
  });

  useNuiEvent<Props>("showContext", (data) => {
    setContextMenu(data);
    setVisible(true);
  });

  return (
    <>
      <Box position="absolute" w="xs" h="fit-content" top="20%" right="25%">
        <Box borderRadius="md" bg="gray.700" mb={3}>
          <Text
            fontFamily="Poppins"
            fontSize="md"
            p={2}
            textAlign="center"
            fontWeight="light"
          >
            {contextMenu.title}
          </Text>
        </Box>
        {Object.keys(contextMenu.options).map((option) => (
          <Box
            bg="gray.700"
            borderRadius="md"
            h="fit-content"
            w="100%"
            p={2}
            mb={1}
            fontFamily="Poppins"
            fontSize="md"
            transition="300ms"
            _hover={{ bg: "gray.800" }}
          >
            {/* TODO: react-markdown (?) */}
            <Text>{option}</Text>
            <Text>{contextMenu.options[option].description}</Text>
          </Box>
        ))}
      </Box>
    </>
  );
};

export default ContextMenu;

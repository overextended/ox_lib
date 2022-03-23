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
    description?: string;
    metadata?: string[] | { [key: string]: any };
  };
}

debugData<Props>([
  {
    action: "showContext",
    data: {
      title: "Vehicle garage",
      options: {
        ["Dinka Blista"]: {
          description: "Super cool vehicle",
          metadata: {
            ["Plate"]: "KLT 192",
            ["Status"]: "In garage",
            ["Health"]: "30%",
          },
        },
        ["Elegy Nitro"]: {
          description: "Even cooler vehicle",
          metadata: ["Plate: JGM 971", "Status: In garage"],
        },
      },
    },
  },
]);

const ContextMenu: React.FC = () => {
  const [visible, setVisible] = useState(false);
  const [contextMenu, setContextMenu] = useState<Props>({
    title: "",
    options: { [""]: { description: "", metadata: [""] } },
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
        {Object.entries(contextMenu.options).map((option, index) => (
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
            key={`option-${index}`}
          >
            {/* TODO: react-markdown (?) */}
            <Box paddingBottom={1}>
              <Text w="100%" fontWeight="medium">
                {option[0]}
              </Text>
            </Box>
            {option[1].description && (
              <Box paddingBottom={1}>
                <Text>{option[1].description}</Text>
              </Box>
            )}
            {option[1]?.metadata && Array.isArray(option[1].metadata) ? (
              option[1].metadata.map((metadata: string, index) => (
                <Text key={`context-metadata-${index}`}>{metadata}</Text>
              ))
            ) : (
              <>
                {typeof option[1].metadata === "object" &&
                  Object.entries(option[1].metadata).map(
                    (metadata: { [key: string]: any }, index) => (
                      <Text key={`context-metadata-${index}`}>
                        {metadata[0]}: {metadata[1]}
                      </Text>
                    )
                  )}
              </>
            )}
          </Box>
        ))}
      </Box>
    </>
  );
};

export default ContextMenu;

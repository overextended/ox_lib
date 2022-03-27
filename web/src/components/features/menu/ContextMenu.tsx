import { useNuiEvent } from "../../../hooks/useNuiEvent";
import { Box, Text, Flex, ScaleFade } from "@chakra-ui/react";
import { debugData } from "../../../utils/debugData";
import { useState } from "react";
import { Options } from "../../../interfaces";
import Item from "./Item";

interface Props {
  title: string;
  options: Options;
}

debugData<Props>([
  {
    action: "showContext",
    data: {
      title: "Vehicle garage",
      options: {
        ["Dinka Blista"]: {
          description: "Super cool vehicle",
          subMenu: true,
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
        ["Burger"]: {
          description: "Make a delicious burger",
          metadata: {
            ["Bun"]: 3,
            ["Lettuce"]: 2,
            ["Meat"]: 1,
            ["Tomato"]: 1,
            ["Cheese"]: 2,
          },
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
    <Flex
      position="absolute"
      w="75%"
      h="80%"
      justifyContent="flex-end"
      alignItems="center"
    >
      <ScaleFade in={visible} unmountOnExit>
        <Box w="xs" h={580}>
          <Box borderRadius="md" bg="gray.800" mb={3}>
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
          <Box maxH={560} overflowY="scroll">
            {Object.entries(contextMenu.options).map((option, index) => (
              <Item option={option} key={`context-item-${index}`} />
            ))}
          </Box>
        </Box>
      </ScaleFade>
    </Flex>
  );
};

export default ContextMenu;

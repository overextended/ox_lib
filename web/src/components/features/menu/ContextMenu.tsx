import { useNuiEvent } from "../../../hooks/useNuiEvent";
import { Box, Text, Flex, ScaleFade } from "@chakra-ui/react";
import { debugData } from "../../../utils/debugData";
import { useState } from "react";
import { ContextMenuProps } from "../../../interfaces";
import Item from "./Item";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { fetchNui } from "../../../utils/fetchNui";

debugData<ContextMenuProps>([
  {
    action: "showContext",
    data: {
      title: "Vehicle garage",
      options: {
        "Dinka Blista": {
          description: "Super cool vehicle",
          menu: "some_other_identifier",
          metadata: {
            Plate: "KLT 192",
            Status: "In garage",
            Health: "30%",
          },
        },
        "Elegy Nitro": {
          description: "Even cooler vehicle",
          metadata: ["Plate: JGM 971", "Status: In garage"],
        },
        Burger: {
          description: "Make a delicious burger",
          metadata: {
            Bun: 3,
            Lettuce: 2,
            Meat: 1,
            Tomato: 1,
            Cheese: 2,
          },
        },
      },
    },
  },
]);

const openMenu = (id: string | undefined) => {
  fetchNui<ContextMenuProps>("openContext", id);
};

const ContextMenu: React.FC = () => {
  const [visible, setVisible] = useState(false);
  const [contextMenu, setContextMenu] = useState<ContextMenuProps>({
    title: "",
    options: { "": { description: "", metadata: [] } },
  });

  useNuiEvent<ContextMenuProps>("showContext", async (data) => {
    if (visible) {
      setVisible(false);
      await new Promise((resolve) => setTimeout(resolve, 100));
    }
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
          <Flex justifyContent="center" alignItems="center" mb={3}>
            {contextMenu.menu && (
              <Box
                borderRadius="md"
                bg="gray.800"
                h="100%"
                flex="1 15%"
                textAlign="center"
                marginRight={2}
                p={2}
                _hover={{ bg: "gray.700" }}
                transition="300ms"
                onClick={() => openMenu(contextMenu.menu)}
              >
                <FontAwesomeIcon icon="chevron-left" />
              </Box>
            )}
            <Box borderRadius="md" bg="gray.800" flex="1 85%">
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
          </Flex>
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

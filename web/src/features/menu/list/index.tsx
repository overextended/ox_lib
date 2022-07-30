import { Box, Stack } from "@chakra-ui/react";
import { useEffect, useRef, useState } from "react";
import { useNuiEvent } from "../../../hooks/useNuiEvent";
import { debugData } from "../../../utils/debugData";
import ListItem from "./ListItem";
import Header from "./Header";
import FocusTrap from "focus-trap-react";
import { IconProp } from "@fortawesome/fontawesome-svg-core";
import { fetchNui } from "../../../utils/fetchNui";

export interface MenuItem {
  label: string;
  value: string | string[];
  icon?: IconProp;
}

interface MenuSettings {
  position?: "top-left" | "top-right" | "bottom-left" | "bottom-right";
  title: string;
  items: Array<MenuItem>;
}

debugData<MenuSettings>([
  {
    action: "setMenu",
    data: {
      //   position: "bottom-left",
      title: "Vehicle garage",
      items: [
        { label: "Option 1", value: "option1", icon: "heart" },
        { label: "Option 2", value: "option2", icon: "basket-shopping" },
        { label: "Vehicle class", value: ["Nice", "Super nice", "Extra nice"], icon: "tag" },
        { label: "Option 1", value: "option1" },
        { label: "Option 2", value: "option2" },
        { label: "Vehicle class", value: ["Nice", "Super nice", "Extra nice"] },
        { label: "Option 1", value: "option1" },
        { label: "Option 2", value: "option2" },
        { label: "Vehicle class", value: ["Nice", "Super nice", "Extra nice"] },
      ],
    },
  },
]);

const ListMenu: React.FC = () => {
  const [menu, setMenu] = useState<MenuSettings>({
    position: "top-left",
    title: "",
    items: [],
  });
  const [selected, setSelected] = useState(0);
  const [visible, setVisible] = useState(false);
  const [indexStates, setIndexStates] = useState<Record<number, number>>({});
  const listRefs = useRef<Array<HTMLDivElement | null>>([]);

  const moveMenu = (e: React.KeyboardEvent<HTMLDivElement>) => {
    switch (e.code) {
      case "ArrowDown":
        setSelected((selected) => {
          if (selected >= menu.items.length - 1) return selected;
          return selected + 1;
        });
        break;
      case "ArrowUp":
        setSelected((selected) => {
          if (selected <= 0) return selected;
          return selected - 1;
        });
        break;
      case "ArrowRight":
        if (!Array.isArray(menu.items[selected].value)) return;
        setIndexStates({
          ...indexStates,
          [selected]:
            indexStates[selected] + 1 <= menu.items[selected].value.length - 1
              ? indexStates[selected] + 1
              : indexStates[selected],
        });
        break;
      case "ArrowLeft":
        if (!Array.isArray(menu.items[selected].value)) return;
        setIndexStates({
          ...indexStates,
          [selected]: indexStates[selected] - 1 >= 0 ? indexStates[selected] - 1 : indexStates[selected],
        });
        break;
      case "Enter":
        fetchNui(
          "confirmSelected",
          Array.isArray(menu.items[selected].value)
            ? menu.items[selected].value[indexStates[selected]]
            : menu.items[selected].value
        );
        setVisible(false);
        break;
    }
  };

  // TODO: add debounce so that callbacks can't be spammed
  useEffect(() => {
    if (!menu.items[selected]?.value) return;
    listRefs.current[selected]?.focus();
    fetchNui(
      "changeSelected",
      Array.isArray(menu.items[selected].value)
        ? menu.items[selected].value[indexStates[selected]]
        : menu.items[selected].value
    );
  }, [selected, menu, indexStates]);

  useNuiEvent("setMenu", (data: MenuSettings) => {
    if (!data.position) data.position = "top-left";
    setMenu(data);
    setVisible(true);
    let arrayIndexes: { [key: number]: number } = {};
    for (let i = 0; i < data.items.length; i++) {
      if (Array.isArray(data.items[i].value)) arrayIndexes[i] = 0;
    }
    setIndexStates(arrayIndexes);
    listRefs.current[0]?.focus();
  });

  return (
    <>
      <Box
        position="absolute"
        pointerEvents="none"
        pt={menu.position === "top-left" || menu.position === "top-right" ? 5 : 0}
        pl={menu.position === "top-left" || menu.position === "bottom-left" ? 5 : 0}
        pr={menu.position === "top-right" || menu.position === "bottom-right" ? 5 : 0}
        pb={menu.position === "bottom-left" || menu.position === "bottom-right" ? 5 : 0}
        right={menu.position === "top-right" || menu.position === "bottom-right" ? 1 : undefined}
        left={menu.position === "bottom-left" ? 1 : undefined}
        bottom={menu.position === "bottom-left" || menu.position === "bottom-right" ? 1 : undefined}
      >
        <Header title={menu.title} />
        <Box
          width="sm"
          height="fit-content"
          maxHeight={415}
          overflow="hidden"
          borderRadius="md"
          bg="#141517"
          fontFamily="Nunito"
          borderTopLeftRadius="none"
          borderTopRightRadius="none"
          onKeyDown={(e) => moveMenu(e)}
        >
          <FocusTrap active={visible}>
            <Stack direction="column" p={2} overflowY="scroll">
              {menu.items.map((item, index) => (
                <ListItem
                  index={index}
                  item={item}
                  scrollIndex={indexStates[index]}
                  ref={listRefs}
                  key={`menu-item-${index}`}
                />
              ))}
            </Stack>
          </FocusTrap>
        </Box>
      </Box>
    </>
  );
};

export default ListMenu;

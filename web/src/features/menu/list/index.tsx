import { Box, Stack, Tooltip } from '@chakra-ui/react';
import { useEffect, useRef, useState } from 'react';
import { useNuiEvent } from '../../../hooks/useNuiEvent';
import ListItem from './ListItem';
import Header from './Header';
import FocusTrap from 'focus-trap-react';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import { fetchNui } from '../../../utils/fetchNui';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import React from 'react';

export interface MenuItem {
  label: string;
  values?: string[];
  description?: string;
  icon?: IconProp;
  defaultIndex?: number;
  close?: boolean;
}

export interface MenuSettings {
  position?: 'top-left' | 'top-right' | 'bottom-left' | 'bottom-right';
  title: string;
  canClose?: boolean;
  items: Array<MenuItem>;
  startItemIndex?: number;
}

const ListMenu: React.FC = () => {
  const [menu, setMenu] = useState<MenuSettings>({
    position: 'top-left',
    title: '',
    items: [],
  });
  const [selected, setSelected] = useState(0);
  const [visible, setVisible] = useState(false);
  const [indexStates, setIndexStates] = useState<Record<number, number>>({});
  const listRefs = useRef<Array<HTMLDivElement | null>>([]);
  const isSetMenuEvent = useRef(false);

  const closeMenu = (ignoreFetch?: boolean, keyPressed?: string, forceClose?: boolean) => {
    if (menu.canClose === false && !forceClose) return;
    setVisible(false);
    if (!ignoreFetch) fetchNui('closeMenu', keyPressed);
  };

  const moveMenu = (e: React.KeyboardEvent<HTMLDivElement>) => {
    switch (e.code) {
      case 'ArrowDown':
        setSelected((selected) => {
          if (selected >= menu.items.length - 1) return (selected = 0);
          return selected + 1;
        });
        break;
      case 'ArrowUp':
        setSelected((selected) => {
          if (selected <= 0) return (selected = menu.items.length - 1);
          return selected - 1;
        });
        break;
      case 'ArrowRight':
        if (!Array.isArray(menu.items[selected].values)) return;
        setIndexStates({
          ...indexStates,
          [selected]:
            indexStates[selected] + 1 <= menu.items[selected].values?.length! - 1
              ? indexStates[selected] + 1
              : (indexStates[selected] = 0),
        });
        break;
      case 'ArrowLeft':
        if (!Array.isArray(menu.items[selected].values)) return;
        setIndexStates({
          ...indexStates,
          [selected]:
            indexStates[selected] - 1 >= 0
              ? indexStates[selected] - 1
              : (indexStates[selected] = menu.items[selected].values?.length! - 1),
        });
        break;
      case 'Enter':
        if (!menu.items[selected]) return;
        fetchNui('confirmSelected', [selected, indexStates[selected]]).catch();
        if (menu.items[selected].close === undefined || menu.items[selected].close) setVisible(false);
        break;
    }
  };

  useEffect(() => {
    if (!menu.items[selected]?.values) return;
    if (isSetMenuEvent.current) {
      isSetMenuEvent.current = false;
      return;
    }
    const timer = setTimeout(() => {
      fetchNui('changeIndex', [selected, indexStates[selected]]).catch();
    }, 100);
    return () => clearTimeout(timer);
  }, [indexStates]);

  useEffect(() => {
    if (!menu.items[selected]) return;
    listRefs.current[selected]?.scrollIntoView({
      block: 'nearest',
      inline: 'start',
    });
    listRefs.current[selected]?.focus({ preventScroll: true });
    // debounces the callback to avoid spam
    const timer = setTimeout(() => {
      fetchNui('changeSelected', [selected, indexStates[selected]]).catch();
    }, 100);
    return () => clearTimeout(timer);
  }, [selected, menu]);

  useEffect(() => {
    if (!visible) return;

    const keyHandler = (e: KeyboardEvent) => {
      if (['Escape', 'Backspace'].includes(e.code)) closeMenu(false, e.code);
    };

    window.addEventListener('keydown', keyHandler);

    return () => window.removeEventListener('keydown', keyHandler);
  }, [visible]);

  useNuiEvent('closeMenu', () => closeMenu(true, undefined, true));

  useNuiEvent('setMenu', (data: MenuSettings) => {
    isSetMenuEvent.current = true;
    if (!data.startItemIndex || data.startItemIndex < 0) data.startItemIndex = 0;
    else if (data.startItemIndex >= data.items.length) data.startItemIndex = data.items.length - 1;
    setSelected(data.startItemIndex);
    if (!data.position) data.position = 'top-left';
    listRefs.current = [];
    setMenu(data);
    setVisible(true);
    let arrayIndexes: { [key: number]: number } = {};
    for (let i = 0; i < data.items.length; i++) {
      if (Array.isArray(data.items[i].values)) arrayIndexes[i] = (data.items[i].defaultIndex || 1) - 1;
    }
    setIndexStates(arrayIndexes);
    listRefs.current[data.startItemIndex]?.focus();
  });

  return (
    <>
      {visible && (
        <Tooltip
          label={menu.items[selected].description}
          isOpen={!!menu.items[selected].description}
          bg="#25262B"
          color="#909296"
          placement="bottom"
          borderRadius="md"
          fontFamily="Nunito"
        >
          <Box
            position="absolute"
            pointerEvents="none"
            mt={menu.position === 'top-left' || menu.position === 'top-right' ? 5 : 0}
            ml={menu.position === 'top-left' || menu.position === 'bottom-left' ? 5 : 0}
            mr={menu.position === 'top-right' || menu.position === 'bottom-right' ? 5 : 0}
            mb={menu.position === 'bottom-left' || menu.position === 'bottom-right' ? 5 : 0}
            right={menu.position === 'top-right' || menu.position === 'bottom-right' ? 1 : undefined}
            left={menu.position === 'bottom-left' ? 1 : undefined}
            bottom={menu.position === 'bottom-left' || menu.position === 'bottom-right' ? 1 : undefined}
          >
            <Header title={menu.title} />
            <Box
              width="sm"
              height="fit-content"
              maxHeight={415}
              overflow="hidden"
              borderRadius={menu.items.length <= 6 || selected === menu.items.length - 1 ? 'md' : undefined}
              bg="#141517"
              fontFamily="Nunito"
              borderTopLeftRadius="none"
              borderTopRightRadius="none"
              onKeyDown={(e) => moveMenu(e)}
            >
              <FocusTrap active={visible}>
                <Stack direction="column" p={2} overflowY="scroll">
                  {menu.items.map((item, index) => (
                    <React.Fragment key={`menu-item-${index}`}>
                      {item.label && (
                        <ListItem index={index} item={item} scrollIndex={indexStates[index]} ref={listRefs} />
                      )}
                    </React.Fragment>
                  ))}
                </Stack>
              </FocusTrap>
            </Box>
            {menu.items.length > 6 && selected !== menu.items.length - 1 && (
              <Box bg="#141517" textAlign="center" borderBottomLeftRadius="md" borderBottomRightRadius="md" height={25}>
                <FontAwesomeIcon icon="chevron-down" color="#909296" fontSize={20} />
              </Box>
            )}
          </Box>
        </Tooltip>
      )}
    </>
  );
};

export default ListMenu;

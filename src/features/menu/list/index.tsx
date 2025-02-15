import { Box, createStyles, Stack, Tooltip } from '@mantine/core';
import FocusTrap from 'focus-trap-react';
import React, { useCallback, useEffect, useRef, useState } from 'react';
import LibIcon from '../../../components/LibIcon';
import { useNuiEvent } from '../../../hooks/useNuiEvent';
import type { MenuPosition, MenuSettings } from '../../../typings';
import { fetchNui } from '../../../utils/fetchNui';
import Header from './Header';
import ListItem from './ListItem';

const useStyles = createStyles((theme, params: { position?: MenuPosition; itemCount: number; selected: number }) => ({
  tooltip: {
    backgroundColor: 'rgba(0, 0, 0, 0.75)',
    color: '#FFFFFF',
    borderRadius: 8,
    maxWidth: 350,
    whiteSpace: 'normal',
    padding: '8px 16px',
    fontSize: 14,
    fontWeight: 500,
  },
  container: {
    position: 'absolute',
    pointerEvents: 'none',
    top: '50%',
    right: 64,
    transform: 'translateY(-50%)',
    fontFamily: 'Albert Sans',
    width: 384,
    height: 'fit-content',
  },
  buttonsWrapper: {
    height: 'fit-content',
    maxHeight: 415,
    overflow: 'hidden',
    borderRadius: 16,
    backgroundColor: 'rgba(0, 0, 0, 0.75)',
    padding: 0,
  },
  scrollArrow: {
    textAlign: 'center',
    height: 25,
    position: 'fixed',
    left: '50%',
    transform: 'translateX(-50%)',
  },
  scrollArrowIcon: {
    color: 'rgba(228, 0, 0, 0.5)',
    fontSize: 20,
  },
  customGradient: {
    position: 'absolute',
    top: 0,
    right: 0,
    width: '50%',
    height: '100%',
    background: 'linear-gradient(90deg, rgba(0,0,0,0) 0%, rgba(0,0,0,0.75) 100%)',
  },
  divider: {
    width: '100%',
    height: 1,
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
  },
}));

const ListMenu: React.FC = () => {
  const [menu, setMenu] = useState<MenuSettings>({
    title: '',
    items: [],
  });
  const [selected, setSelected] = useState(0);
  const [visible, setVisible] = useState(false);
  const [indexStates, setIndexStates] = useState<Record<number, number>>({});
  const [checkedStates, setCheckedStates] = useState<Record<number, boolean>>({});
  const listRefs = useRef<Array<HTMLDivElement | null>>([]);
  const firstRenderRef = useRef(false);
  const { classes } = useStyles({ position: menu.position, itemCount: menu.items.length, selected });

  const closeMenu = (ignoreFetch?: boolean, keyPressed?: string, forceClose?: boolean) => {
    if (menu.canClose === false && !forceClose) return;
    setVisible(false);
    if (!ignoreFetch) fetchNui('closeMenu', keyPressed);
  };

  const moveMenu = (e: React.KeyboardEvent<HTMLDivElement>) => {
    if (firstRenderRef.current) firstRenderRef.current = false;
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
        if (Array.isArray(menu.items[selected].values))
          setIndexStates({
            ...indexStates,
            [selected]:
              indexStates[selected] + 1 <= menu.items[selected].values?.length! - 1 ? indexStates[selected] + 1 : 0,
          });
        break;
      case 'ArrowLeft':
        if (Array.isArray(menu.items[selected].values))
          setIndexStates({
            ...indexStates,
            [selected]:
              indexStates[selected] - 1 >= 0 ? indexStates[selected] - 1 : menu.items[selected].values?.length! - 1,
          });

        break;
      case 'Enter':
        if (!menu.items[selected]) return;
        if (menu.items[selected].checked !== undefined && !menu.items[selected].values) {
          return setCheckedStates({
            ...checkedStates,
            [selected]: !checkedStates[selected],
          });
        }
        fetchNui('confirmSelected', [selected, indexStates[selected]]).catch();
        if (menu.items[selected].close === undefined || menu.items[selected].close) setVisible(false);
        break;
    }
  };

  useEffect(() => {
    if (menu.items[selected]?.checked === undefined || firstRenderRef.current) return;
    const timer = setTimeout(() => {
      fetchNui('changeChecked', [selected, checkedStates[selected]]).catch();
    }, 100);
    return () => clearTimeout(timer);
  }, [checkedStates]);

  useEffect(() => {
    if (!menu.items[selected]?.values || firstRenderRef.current) return;
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
      fetchNui('changeSelected', [
        selected,
        menu.items[selected].values
          ? indexStates[selected]
          : menu.items[selected].checked
          ? checkedStates[selected]
          : null,
        menu.items[selected].values ? 'isScroll' : menu.items[selected].checked ? 'isCheck' : null,
      ]).catch();
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

  const isValuesObject = useCallback(
    (values?: Array<string | { label: string; description: string }>) => {
      return Array.isArray(values) && typeof values[indexStates[selected]] === 'object';
    },
    [indexStates, selected]
  );

  useNuiEvent('closeMenu', () => closeMenu(true, undefined, true));

  useNuiEvent('setMenu', (data: MenuSettings) => {
    firstRenderRef.current = true;
    if (!data.startItemIndex || data.startItemIndex < 0) data.startItemIndex = 0;
    else if (data.startItemIndex >= data.items.length) data.startItemIndex = data.items.length - 1;
    setSelected(data.startItemIndex);
    if (!data.position) data.position = 'top-left';
    listRefs.current = [];
    setMenu(data);
    setVisible(true);
    const arrayIndexes: { [key: number]: number } = {};
    const checkedIndexes: { [key: number]: boolean } = {};
    for (let i = 0; i < data.items.length; i++) {
      if (Array.isArray(data.items[i].values)) arrayIndexes[i] = (data.items[i].defaultIndex || 1) - 1;
      else if (data.items[i].checked !== undefined) checkedIndexes[i] = data.items[i].checked || false;
    }
    setIndexStates(arrayIndexes);
    setCheckedStates(checkedIndexes);
    listRefs.current[data.startItemIndex]?.focus();
  });

  return (
    <>
      {visible && (
        <>
          <div className={classes.customGradient}></div>

          <Tooltip
            label={
              isValuesObject(menu.items[selected].values)
                ? // @ts-ignore
                  menu.items[selected].values[indexStates[selected]].description
                : menu.items[selected].description
            }
            opened={
              isValuesObject(menu.items[selected].values)
                ? // @ts-ignore
                  !!menu.items[selected].values[indexStates[selected]].description
                : !!menu.items[selected].description
            }
            transitionDuration={0}
            classNames={{ tooltip: classes.tooltip }}
          >
            <Box className={classes.container}>
              <Header title={menu.title} />
              <Box
                className={classes.buttonsWrapper}
                onKeyDown={(e: React.KeyboardEvent<HTMLDivElement>) => moveMenu(e)}
              >
                <FocusTrap active={visible}>
                  <Stack spacing={0} p={0} sx={{ overflowY: 'scroll' }}>
                    {menu.items.map((item, index) => (
                      <React.Fragment key={`menu-item-${index}`}>
                        {item.label && (
                          <>
                            <ListItem
                              index={index}
                              item={item}
                              scrollIndex={indexStates[index]}
                              checked={checkedStates[index]}
                              ref={listRefs}
                            />
                            <div className={classes.divider}></div>
                          </>
                        )}
                      </React.Fragment>
                    ))}
                  </Stack>
                </FocusTrap>
              </Box>
              {menu.items.length > 6 && selected !== menu.items.length - 1 && (
                <Box className={classes.scrollArrow}>
                  <LibIcon icon="chevron-down" className={classes.scrollArrowIcon} />
                </Box>
              )}
            </Box>
          </Tooltip>
        </>
      )}
    </>
  );
};

export default ListMenu;

import { ActionIcon, Box, createStyles, Stack, Text, Transition } from '@mantine/core';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import { useState } from 'react';
import { useNuiEvent } from '../../../hooks/useNuiEvent';
import { debugData } from '../../../utils/debugData';
import { fetchNui } from '../../../utils/fetchNui';

const radius = 60;

// https://codesandbox.io/embed/circular-menu-e94ug
function getTransform(index: number, totalItems: number) {
  const value = index / totalItems;

  const x = radius * Math.cos(Math.PI * 2 * (value - 0.25));
  const y = radius * Math.sin(Math.PI * 2 * (value - 0.25));

  return `translate(${x}px, ${y}px)`;
}

interface MenuItem {
  icon: IconProp;
  label: string;
}

debugData<{ items: MenuItem[]; sub?: boolean }>([
  {
    action: 'openPlanetMenu',
    data: {
      items: [
        { icon: 'palette', label: 'Paint' },
        { icon: 'warehouse', label: 'Garage' },
        { icon: 'handcuffs', label: 'Arrest' },
        { icon: 'handcuffs', label: 'Arrest' },
      ],
      sub: false,
    },
  },
]);

const useStyles = createStyles((theme) => ({
  wrapper: {
    position: 'absolute',
    top: '50%',
    left: '50%',
    transform: 'translate(-50%, -50%)',
  },
  centerButton: {
    width: 50,
    height: 50,
    zIndex: 99,
  },
  buttonsContainer: {
    position: 'absolute',
    top: '50%',
    left: '50%',
    transform: 'translate(-50%, -50%)',
    width: 120,
    height: 120,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },
  button: {
    position: 'absolute',
    width: 40,
    height: 40,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: '50%',
    backgroundColor: theme.colors.dark[6],
    color: theme.colors.dark[0],
    boxShadow: theme.shadows.sm,
    padding: 12,
    '&:hover': {
      backgroundColor: theme.colors.dark[5],
      cursor: 'pointer',
    },
  },
  labelWrapper: {
    marginTop: 120,
    position: 'absolute',
    width: '100%',
    top: '50%',
    left: '50%',
    transform: 'translate(-50%, -50%)',
  },
  labelContainer: {
    backgroundColor: theme.colors.dark[6],
    color: theme.colors.dark[2],
    padding: 8,
    borderRadius: theme.radius.sm,
    fontWeight: 500,
    fontSize: 14,
    boxShadow: theme.shadows.sm,
    textAlign: 'center',
  },
}));

const PlanetMenu: React.FC = () => {
  const { classes } = useStyles();
  const [visible, setVisible] = useState(false);
  const [menu, setMenu] = useState<{ items: MenuItem[]; sub?: boolean }>({
    items: [],
    sub: false,
  });
  const [currentItem, setCurrentItem] = useState({ label: '', visible: false });

  useNuiEvent('openPlanetMenu', (data: { items: MenuItem[]; sub?: boolean }) => {
    setMenu(data);
    setVisible(true);
  });

  const handleItemClick = (index: number) => {
    // fetchNui('planetClick', index)
    // setVisible(false);
  };

  return (
    <>
      <Box className={classes.wrapper}>
        <>
          {visible && (
            <>
              <ActionIcon variant="filled" radius="xl" size="xl" color="primary" className={classes.centerButton}>
                <FontAwesomeIcon fixedWidth icon="xmark" size="lg" />
              </ActionIcon>
              <Box className={classes.buttonsContainer}>
                {menu.items.map((item, index) => (
                  <Box
                    onMouseEnter={() => setCurrentItem({ label: item.label, visible: true })}
                    onMouseLeave={() => setCurrentItem((prevState) => ({ ...prevState, visible: false }))}
                    onClick={() => handleItemClick(index)}
                    sx={{
                      transform: getTransform(index, menu.items.length),
                    }}
                    className={classes.button}
                  >
                    <FontAwesomeIcon icon={item.icon} fixedWidth />
                  </Box>
                ))}
              </Box>
            </>
          )}
        </>
      </Box>
      <Stack justify="center" align="center" className={classes.labelWrapper}>
        <Transition transition="fade" mounted={currentItem.visible}>
          {(styles) => (
            <Box style={styles} className={classes.labelContainer}>
              <Text>{currentItem.label}</Text>
            </Box>
          )}
        </Transition>
      </Stack>
    </>
  );
};

export default PlanetMenu;

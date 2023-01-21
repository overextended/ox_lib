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
        { icon: 'palette', label: 'Paint' },
        // { icon: 'warehouse', label: 'Garage' },
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
  sector: {
    fill: theme.colors.dark[6],
    color: theme.colors.dark[0],
    '&:hover': {
      fill: theme.fn.primaryColor(),
    },
    stroke: '#fff',
    strokeWidth: '1px',
  },
  circleIcon: {
    // position: 'relative',
  },
}));

const degToRad = (deg: number) => deg * (Math.PI / 180);

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
        <svg width="500px" height="500px" transform="rotate(90)">
          {menu.items.map((item, index) => {
            // TODO: center labels and icon inside sector
            const pieAngle = 360 / menu.items.length;
            const angle = degToRad(pieAngle / 2 + 90);
            const radius = 250 / 2;
            const iconX = 250 + Math.sin(angle) * radius;
            const iconY = 250 + Math.cos(angle) * radius;

            return (
              <>
                <g transform={`rotate(-${index * pieAngle} 250 250)`}>
                  <path
                    className={classes.sector}
                    d={`M250,250 l250,0 A250,250 0 0,0 ${250 + 250 * Math.cos(-degToRad(pieAngle))}, ${
                      250 + 250 * Math.sin(-degToRad(pieAngle))
                    } z`}
                  />
                  <text x={iconX} y={iconY} textAnchor="middle" fill="#fff" width={50} height={50}>
                    {item.label}
                  </text>
                  {/*<FontAwesomeIcon*/}
                  {/*  icon={item.icon}*/}
                  {/*  fixedWidth*/}
                  {/*  className={classes.circleIcon}*/}
                  {/*  width={50}*/}
                  {/*  height={50}*/}
                  {/*  x={iconX}*/}
                  {/*  y={iconY}*/}
                  {/*  // transform="translate(-5,-5)"*/}
                  {/*/>*/}
                </g>
              </>
            );
          })}
        </svg>
      </Box>
    </>
  );
};

export default PlanetMenu;

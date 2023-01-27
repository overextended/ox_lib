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
    action: 'openRadialMenu',
    data: {
      items: [
        // TODO: Fix wheel being broken when there's only one item
        { icon: 'palette', label: 'Paint' },
        { icon: 'warehouse', label: 'Garage' },
        { icon: 'palette', label: 'Quite long text' },
        { icon: 'palette', label: 'Paint' },
        { icon: 'warehouse', label: 'Garage' },
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
  sector: {
    fill: theme.colors.dark[6],
    color: theme.colors.dark[0],

    '&:hover': {
      fill: theme.fn.primaryColor(),
      cursor: 'pointer',
      '> g > text, > g > svg > path': {
        fill: '#fff',
      },
    },
    '> g > text': {
      fill: theme.colors.dark[0],
    },
  },
  backgroundCircle: {
    fill: theme.colors.dark[6],
  },
  centerCircle: {
    fill: theme.fn.primaryColor(),
    color: '#fff',
    '&:hover': {
      fill: theme.colors[theme.primaryColor][theme.fn.primaryShade() - 1],
      cursor: 'pointer',
    },
  },
  centerIcon: {
    color: '#fff',
    pointerEvents: 'none',
  },
}));

const degToRad = (deg: number) => deg * (Math.PI / 180);

const RadialMenu: React.FC = () => {
  const { classes } = useStyles();
  const [visible, setVisible] = useState(false);
  const [menu, setMenu] = useState<{ items: MenuItem[]; sub?: boolean }>({
    items: [],
    sub: false,
  });

  useNuiEvent('openRadialMenu', (data: { items: MenuItem[]; sub?: boolean }) => {
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
        <svg width="350px" height="350px" transform="rotate(90)">
          <g transform="translate(175, 175)">
            <circle r={175} className={classes.backgroundCircle} />
          </g>
          {menu.items.map((item, index) => {
            const pieAngle = 360 / menu.items.length;
            const angle = degToRad(pieAngle / 2 + 90);
            const radius = 175 * 0.65;
            const iconX = 175 + Math.sin(angle) * radius;
            const iconY = 175 + Math.cos(angle) * radius;

            return (
              <>
                <g transform={`rotate(-${index * pieAngle} 175 175)`} className={classes.sector}>
                  <path
                    d={`M175.01,175.01 l175,0 A175.01,175.01 0 0,0 ${175 + 175 * Math.cos(-degToRad(pieAngle))}, ${
                      175 + 175 * Math.sin(-degToRad(pieAngle))
                    } z`}
                  />
                  <g transform={`rotate(${index * pieAngle - 90} ${iconX} ${iconY})`} pointerEvents="none">
                    <FontAwesomeIcon
                      x={iconX - 12.5}
                      y={iconY - 17.5}
                      icon={item.icon}
                      width={25}
                      height={25}
                      fixedWidth
                    />
                    <text x={iconX} y={iconY + 25} fill="#fff" textAnchor="middle" pointerEvents="none">
                      {item.label}
                    </text>
                  </g>
                </g>
              </>
            );
          })}
          <g transform="translate(175, 175)">
            {/*TODO: Fix background circle when there's 2 items*/}
            <circle r={30} className={classes.centerCircle} />
          </g>
          <FontAwesomeIcon
            icon="xmark"
            className={classes.centerIcon}
            color="#fff"
            width={28}
            height={28}
            x={175 - 28 / 2}
            y={175 - 28 / 2}
          />
        </svg>
      </Box>
    </>
  );
};

export default RadialMenu;

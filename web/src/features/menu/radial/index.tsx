import { Box, createStyles } from '@mantine/core';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import { useState } from 'react';
import { useNuiEvent } from '../../../hooks/useNuiEvent';
import { fetchNui } from '../../../utils/fetchNui';
import ScaleFade from '../../../transitions/ScaleFade';

export interface MenuItem {
  icon: IconProp;
  label: string;
}

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

  useNuiEvent('openRadialMenu', async (data: { items: MenuItem[]; sub?: boolean } | false) => {
    if (!data) return setVisible(false);
    if (visible) {
      setVisible(false);
      await new Promise((resolve) => setTimeout(resolve, 100));
    }
    setMenu(data);
    setVisible(true);
  });

  useNuiEvent('refreshItems', (data: MenuItem[]) => {
    setMenu({ ...menu, items: data });
  });

  const handleClick = async (index: number) => {
    fetchNui('radialClick', index);
    // TODO: shouldClose
    setVisible(false);
  };

  return (
    <>
      <Box className={classes.wrapper}>
        <ScaleFade visible={visible}>
          <svg width="350px" height="350px" transform="rotate(90)">
            {/*Fixed issues with background circle extending the circle when there's less than 3 items*/}
            <g transform="translate(175, 175)">
              <circle r={175} className={classes.backgroundCircle} />
            </g>
            {menu.items.map((item, index) => {
              // Always draw full circle to avoid elipse circles with 2 or less items
              const pieAngle = 360 / (menu.items.length < 3 ? 3 : menu.items.length);
              const angle = degToRad(pieAngle / 2 + 90);
              const radius = 175 * 0.65;
              const iconX = 175 + Math.sin(angle) * radius;
              const iconY = 175 + Math.cos(angle) * radius;

              return (
                <>
                  <g
                    transform={`rotate(-${index * pieAngle} 175 175)`}
                    className={classes.sector}
                    onClick={() => handleClick(index)}
                  >
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
            {/* TODO: rotate go back icon */}
            <g
              transform={`translate(175, 175)`}
              onClick={() => {
                setVisible(false);
                menu.sub && fetchNui('radialBack');
              }}
            >
              <circle r={30} className={classes.centerCircle} />
            </g>
            <FontAwesomeIcon
              icon={!menu.sub ? 'xmark' : 'arrow-rotate-left'}
              className={classes.centerIcon}
              color="#fff"
              width={28}
              height={28}
              x={175 - 28 / 2}
              y={175 - 28 / 2}
            />
          </svg>
        </ScaleFade>
      </Box>
    </>
  );
};

export default RadialMenu;

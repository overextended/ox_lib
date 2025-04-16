import { Box, createStyles } from '@mantine/core';
import { useEffect, useState } from 'react';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import { useNuiEvent } from '../../../hooks/useNuiEvent';
import { fetchNui } from '../../../utils/fetchNui';
import { isIconUrl } from '../../../utils/isIconUrl';
import ScaleFade from '../../../transitions/ScaleFade';
import type { RadialMenuItem } from '../../../typings';
import { useLocales } from '../../../providers/LocaleProvider';
import LibIcon from '../../../components/LibIcon';

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
      strokeWidth: 0,
    },
  },
  backgroundCircle: {
    fill: theme.colors.dark[6],
  },
  centerCircle: {
    fill: theme.fn.primaryColor(),
    color: '#fff',
    stroke: theme.colors.dark[6],
    strokeWidth: 4,
    '&:hover': {
      cursor: 'pointer',
      fill: theme.colors[theme.primaryColor][theme.fn.primaryShade() - 1],
    },
  },
  centerIconContainer: {
    position: 'absolute',
    top: '50%',
    left: '50%',
    transform: 'translate(-50%, -50%)',
    pointerEvents: 'none',
  },
  centerIcon: {
    color: '#fff',
  },
}));

const calculateFontSize = (text: string): number => {
  if (text.length > 20) return 10;
  if (text.length > 15) return 12;
  return 13;
};

const splitTextIntoLines = (text: string, maxCharPerLine: number = 15): string[] => {
  const words = text.split(' ');
  const lines: string[] = [];
  let currentLine = words[0];

  for (let i = 1; i < words.length; i++) {
    if (currentLine.length + words[i].length + 1 <= maxCharPerLine) {
      currentLine += ' ' + words[i];
    } else {
      lines.push(currentLine);
      currentLine = words[i];
    }
  }
  lines.push(currentLine);
  return lines;
};

const PAGE_ITEMS = 6;

const degToRad = (deg: number) => deg * (Math.PI / 180);

const RadialMenu: React.FC = () => {
  const { classes } = useStyles();
  const { locale } = useLocales();
  // We'll make these values relative to viewport size
  const svgSize = 350;
  const [visible, setVisible] = useState(false);
  const [menuItems, setMenuItems] = useState<RadialMenuItem[]>([]);
  const [menu, setMenu] = useState<{ items: RadialMenuItem[]; sub?: boolean; page: number }>({
    items: [],
    sub: false,
    page: 1,
  });

  const changePage = async (increment?: boolean) => {
    setVisible(false);

    const didTransition: boolean = await fetchNui('radialTransition');

    if (!didTransition) return;

    setVisible(true);
    setMenu({ ...menu, page: increment ? menu.page + 1 : menu.page - 1 });
  };

  useEffect(() => {
    if (menu.items.length <= PAGE_ITEMS) return setMenuItems(menu.items);
    const items = menu.items.slice(
      PAGE_ITEMS * (menu.page - 1) - (menu.page - 1),
      PAGE_ITEMS * menu.page - menu.page + 1
    );
    if (PAGE_ITEMS * menu.page - menu.page + 1 < menu.items.length) {
      items[items.length - 1] = { icon: 'ellipsis-h', label: locale.ui.more, isMore: true };
    }
    setMenuItems(items);
  }, [menu.items, menu.page]);

  useNuiEvent('openRadialMenu', async (data: { items: RadialMenuItem[]; sub?: boolean; option?: string } | false) => {
    if (!data) return setVisible(false);
    let initialPage = 1;
    if (data.option) {
      data.items.findIndex(
        (item, index) => item.menu == data.option && (initialPage = Math.floor(index / PAGE_ITEMS) + 1)
      );
    }
    setMenu({ ...data, page: initialPage });
    setVisible(true);
  });

  useNuiEvent('refreshItems', (data: RadialMenuItem[]) => {
    setMenu({ ...menu, items: data });
  });

  return (
    <>
      <Box
        className={classes.wrapper}
        onContextMenu={async () => {
          if (menu.page > 1) await changePage();
          else if (menu.sub) fetchNui('radialBack');
        }}
      >
        <ScaleFade visible={visible}>
          <svg
            style={{ overflow: 'visible' }}
            width="100%"
            height="100%"
            viewBox={`0 0 ${svgSize} ${svgSize}`}
            transform="rotate(90)"
          >
            {/* Fixed issues with background circle extending the circle when there's less than 3 items */}
            <g transform={`translate(${svgSize / 2}, ${svgSize / 2})`}>
              <circle r={svgSize / 2} className={classes.backgroundCircle} />
            </g>
            {menuItems.map((item, index) => {
              const pieAngle = 360 / (menuItems.length < 3 ? 3 : menuItems.length);
              const angle = degToRad(pieAngle / 2 + 90);
              const gap = 1;
              const radius = (svgSize / 2) * 0.65 - gap;
              const sinAngle = Math.sin(angle);
              const cosAngle = Math.cos(angle);
              const iconYOffset = splitTextIntoLines(item.label, 15).length > 3 ? 3 : 0;
              const iconX = svgSize / 2 + sinAngle * radius;
              const iconY = svgSize / 2 + cosAngle * radius + iconYOffset; // Apply the Y offset to iconY
              const iconWidth = Math.min(Math.max(item.iconWidth || 50, 0), 100);
              const iconHeight = Math.min(Math.max(item.iconHeight || 50, 0), 100);

              return (
                <g
                  transform={`rotate(-${index * pieAngle} ${svgSize / 2} ${svgSize / 2}) translate(${sinAngle * gap}, ${
                    cosAngle * gap
                  })`}
                  className={classes.sector}
                  onClick={async () => {
                    const clickIndex = menu.page === 1 ? index : PAGE_ITEMS * (menu.page - 1) - (menu.page - 1) + index;
                    if (!item.isMore) fetchNui('radialClick', clickIndex);
                    else {
                      await changePage(true);
                    }
                  }}
                >
                  <path
                    d={`M${svgSize / 2},${svgSize / 2} l${svgSize / 2 - gap},0 A${svgSize / 2},${svgSize / 2} 0 0,0 ${
                      svgSize / 2 + (svgSize / 2 - gap) * Math.cos(-degToRad(pieAngle))
                    }, ${svgSize / 2 + (svgSize / 2 - gap) * Math.sin(-degToRad(pieAngle))} z`}
                  />
                  <g transform={`rotate(${index * pieAngle - 90} ${iconX} ${iconY})`} pointerEvents="none">
                    {typeof item.icon === 'string' && isIconUrl(item.icon) ? (
                      <image
                        href={item.icon}
                        width={iconWidth}
                        height={iconHeight}
                        x={iconX - iconWidth / 2}
                        y={iconY - iconHeight / 2 - iconHeight / 4}
                      />
                    ) : (
                      <LibIcon
                        x={iconX - 14.5}
                        y={iconY - 17.5}
                        icon={item.icon as IconProp}
                        width={30}
                        height={30}
                        fixedWidth
                      />
                    )}
                    <text
                      x={iconX}
                      y={iconY + (splitTextIntoLines(item.label, 15).length > 2 ? 15 : 28)}
                      fill="#fff"
                      textAnchor="middle"
                      fontSize={calculateFontSize(item.label)}
                      pointerEvents="none"
                      lengthAdjust="spacingAndGlyphs"
                    >
                      {splitTextIntoLines(item.label, 15).map((line, index) => (
                        <tspan x={iconX} dy={index === 0 ? 0 : '1.2em'} key={index}>
                          {line}
                        </tspan>
                      ))}
                    </text>
                  </g>
                </g>
              );
            })}
            <g
              transform={`translate(${svgSize / 2}, ${svgSize / 2})`}
              onClick={async () => {
                if (menu.page > 1) await changePage();
                else {
                  if (menu.sub) fetchNui('radialBack');
                  else {
                    setVisible(false);
                    fetchNui('radialClose');
                  }
                }
              }}
            >
              <circle r={28} className={classes.centerCircle} />
            </g>
          </svg>
          <div className={classes.centerIconContainer}>
            <LibIcon
              icon={!menu.sub && menu.page < 2 ? 'xmark' : 'arrow-rotate-left'}
              fixedWidth
              className={classes.centerIcon}
              color="#fff"
              size="2x"
            />
          </div>
        </ScaleFade>
      </Box>
    </>
  );
};

export default RadialMenu;

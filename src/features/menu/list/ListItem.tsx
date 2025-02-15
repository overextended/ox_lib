import { IconProp } from '@fortawesome/fontawesome-svg-core';
import { Box, createStyles, Group, Progress, Stack, Text } from '@mantine/core';
import React, { forwardRef } from 'react';
import LibIcon from '../../../components/LibIcon';
import type { MenuItem } from '../../../typings';
import { isIconUrl } from '../../../utils/isIconUrl';
import CustomCheckbox from './CustomCheckbox';

interface Props {
  item: MenuItem;
  index: number;
  scrollIndex: number;
  checked: boolean;
}

const useStyles = createStyles((theme, params: { iconColor?: string }) => ({
  buttonContainer: {
    backgroundColor: 'transparent',
    padding: 16,
    height: 60,
    scrollMargin: 8,
    color: 'white',
    fontWeight: 600,
    '&:focus': {
      backgroundColor: 'black',
      outline: 'none',
    },
  },
  iconImage: {
    maxWidth: 32,
    color: 'rgba(255, 255, 255, 0.75)',
  },
  buttonWrapper: {
    paddingLeft: 5,
    paddingRight: 12,
    height: '100%',
  },
  iconContainer: {
    display: 'flex',
    alignItems: 'center',
    width: 32,
    height: 32,
  },
  icon: {
    fontSize: 24,
    color: 'rgba(255, 255, 255, 0.75)',
  },
  label: {
    color: 'rgba(255, 255, 255, 0.75)',
    fontSize: 14,
    verticalAlign: 'middle',
    fontWeight: 500,
  },
  chevronIcon: {
    fontSize: 14,
    color: 'rgba(255, 255, 255, 0.75)',
  },
  scrollIndexValue: {
    color: 'rgba(255, 255, 255, 0.75)',
    textTransform: 'uppercase',
    fontSize: 14,
  },
  progressStack: {
    width: '100%',
    marginRight: 5,
  },
  progressLabel: {
    verticalAlign: 'middle',
    marginBottom: 3,
    fontWeight: 600,
  },
}));

const ListItem = forwardRef<Array<HTMLDivElement | null>, Props>(({ item, index, scrollIndex, checked }, ref) => {
  const { classes } = useStyles({ iconColor: item.iconColor });

  return (
    <Box
      tabIndex={index}
      className={classes.buttonContainer}
      key={`item-${index}`}
      ref={(element: HTMLDivElement) => {
        if (ref)
          // @ts-ignore i cba
          return (ref.current = [...ref.current, element]);
      }}
    >
      <Group spacing={15} noWrap className={classes.buttonWrapper}>
        {item.icon && (
          <Box className={classes.iconContainer}>
            {typeof item.icon === 'string' && isIconUrl(item.icon) ? (
              <img src={item.icon} alt="Missing image" className={classes.iconImage} />
            ) : (
              <LibIcon
                icon={item.icon as IconProp}
                className={classes.icon}
                fixedWidth
                animation={item.iconAnimation}
              />
            )}
          </Box>
        )}
        {Array.isArray(item.values) ? (
          <Group position="apart" w="100%">
            <Stack spacing={0} justify="space-between">
              <Text className={classes.label}>{item.label}</Text>
              <Text>
                {typeof item.values[scrollIndex] === 'object'
                  ? // @ts-ignore for some reason even checking the type TS still thinks it's a string
                    item.values[scrollIndex].label
                  : item.values[scrollIndex]}
              </Text>
            </Stack>
            <Group spacing={1} position="center">
              <LibIcon icon="chevron-left" className={classes.chevronIcon} />
              <Text className={classes.scrollIndexValue}>
                {scrollIndex + 1}/{item.values.length}
              </Text>
              <LibIcon icon="chevron-right" className={classes.chevronIcon} />
            </Group>
          </Group>
        ) : item.checked !== undefined ? (
          <Group position="apart" w="100%">
            <Text>{item.label}</Text>
            <CustomCheckbox checked={checked}></CustomCheckbox>
          </Group>
        ) : item.progress !== undefined ? (
          <Stack className={classes.progressStack} spacing={0}>
            <Text className={classes.progressLabel}>{item.label}</Text>
            <Progress
              value={item.progress}
              size="md"
              color={'rgba(228, 0, 0, 0.5)'}
              bg={'rgba(255, 255, 255, 0.20)'}
            />
          </Stack>
        ) : (
          <Text>{item.label}</Text>
        )}
      </Group>
    </Box>
  );
});

export default React.memo(ListItem);

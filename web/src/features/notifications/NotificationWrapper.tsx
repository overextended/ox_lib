import { useNuiEvent } from '../../hooks/useNuiEvent';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import { toast, Toaster, ToastPosition } from 'react-hot-toast';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import ReactMarkdown from 'react-markdown';
import { Avatar, createStyles, Group, Stack, Box, Text } from '@mantine/core';
import React from 'react';

export interface NotificationProps {
  title?: string;
  description?: string;
  duration?: number;
  position?: ToastPosition | 'top' | 'bottom';
  variant?: string;
  status?: 'info' | 'warning' | 'success' | 'error';
  id?: number;
}

export interface CustomNotificationProps {
  style?: React.CSSProperties;
  description?: string;
  title?: string;
  duration?: number;
  icon?: IconProp;
  iconColor?: string;
  position?: ToastPosition | 'top' | 'bottom';
  id?: number;
  type?: string;
}

const useStyles = createStyles((theme) => ({
  container: {
    width: 300,
    height: 'fit-content',
    backgroundColor: theme.colors.dark[6],
    color: theme.colors.dark[0],
    padding: 12,
    borderRadius: theme.radius.sm,
    fontFamily: 'Roboto',
    boxShadow: theme.shadows.sm,
  },
  title: {
    fontWeight: 500,
  },
  description: {
    fontSize: 12,
    color: theme.colors.dark[2],
    fontFamily: 'Roboto',
  },
}));

const Notifications: React.FC = () => {
  const { classes } = useStyles();

  useNuiEvent<CustomNotificationProps>('customNotify', (data) => {
    if (!data.title && !data.description) return;
    // Backwards compat with old notifications
    let position = data.position;
    switch (position) {
      case 'top':
        position = 'top-center';
        break;
      case 'bottom':
        position = 'bottom-center';
        break;
    }
    if (!data.icon) {
      data.icon = data.type === 'error' ? 'xmark' : data.type === 'success' ? 'check' : 'info';
    }

    toast(
      <Box style={data.style} className={`${classes.container}`}>
        <Group noWrap spacing={12}>
          {data.icon && (
            <>
              {!data.iconColor ? (
                <Avatar
                  color={data.type === 'error' ? 'red' : data.type === 'success' ? 'teal' : 'blue'}
                  radius="xl"
                  size={(data.title && !data.description) || (data.description && !data.title) ? 28 : undefined}
                >
                  <FontAwesomeIcon icon={data.icon} fixedWidth size="lg" />
                </Avatar>
              ) : (
                <FontAwesomeIcon icon={data.icon} style={{ color: data.iconColor }} fixedWidth size="lg" />
              )}
            </>
          )}
          <Stack spacing={0}>
            {data.title && <Text className={classes.title}>{data.title}</Text>}
            {data.description && <ReactMarkdown className={classes.description}>{data.description}</ReactMarkdown>}
          </Stack>
        </Group>
      </Box>,
      {
        id: data.id?.toString(),
        duration: data.duration || 3000,
        position: position || 'top-right',
        style: {
          padding: 0,
          boxShadow: 'none',
          backgroundColor: 'transparent',
        },
      }
    );
  });

  return <Toaster />;
};

export default Notifications;

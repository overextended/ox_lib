import { Button, Box, Group, Stack, Text, Progress, HoverCard, Image, createStyles } from '@mantine/core';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import ReactMarkdown from 'react-markdown';
import { Option, ContextMenuProps } from '../../../../interfaces/context';
import { fetchNui } from '../../../../utils/fetchNui';

const openMenu = (id: string | undefined) => {
  fetchNui<ContextMenuProps>('openContext', { id: id, back: false });
};

const clickContext = (id: string) => {
  fetchNui('clickContext', id);
};

const useStyles = createStyles((theme, params: { disabled?: boolean }) => ({
  inner: {
    justifyContent: 'flex-start',
  },
  label: {
    width: '100%',
    color: params.disabled ? theme.colors.dark[3] : theme.colors.dark[0],
    whiteSpace: 'pre-wrap',
  },
  description: {
    color: params.disabled ? theme.colors.dark[3] : theme.colors.dark[2],
  },
  dropdown: {
    padding: 10,
    color: theme.colors.dark[0],
    fontSize: 14,
    maxWidth: 256,
    width: 'fit-content',
    border: 'none',
  },
}));

const ContextButton: React.FC<{
  option: [string, Option];
}> = ({ option }) => {
  const button = option[1];
  const buttonKey = option[0];
  const { classes } = useStyles({ disabled: button.disabled });

  return (
    <>
      <HoverCard
        position="right-start"
        disabled={button.disabled || !(button.metadata || button.image)}
        openDelay={200}
      >
        <HoverCard.Target>
          <Button
            classNames={{ inner: classes.inner, label: classes.label }}
            onClick={() => (!button.disabled ? (button.menu ? openMenu(button.menu) : clickContext(buttonKey)) : null)}
            variant="default"
            h="fit-content"
            p={10}
            fullWidth
            disabled={button.disabled}
          >
            <Group position="apart" w="100%" noWrap>
              <Stack spacing={4} style={{ flex: '1' }}>
                <Group spacing={8} noWrap>
                  {button?.icon && (
                    <Stack w={25} h={25} justify="center" align="center">
                      <FontAwesomeIcon icon={button.icon} fixedWidth size="lg" style={{ color: button.iconColor }} />
                    </Stack>
                  )}
                  <Text sx={{ overflowWrap: 'break-word' }}>
                    <ReactMarkdown>{button.title || buttonKey}</ReactMarkdown>
                  </Text>
                </Group>
                {button.description && (
                  <Text size={12} className={classes.description}>
                    <ReactMarkdown>{button.description}</ReactMarkdown>
                  </Text>
                )}
                {button?.progress && (
                  <Progress value={button.progress} size="sm" color={button.colorScheme || 'dark.3'} />
                )}
              </Stack>
              {(button.menu || button.arrow) && button.arrow !== false && (
                <Stack justify="center" w={25} h={25} align="center">
                  <FontAwesomeIcon icon="chevron-right" fixedWidth />
                </Stack>
              )}
            </Group>
          </Button>
        </HoverCard.Target>
        <HoverCard.Dropdown className={classes.dropdown}>
          {button.image && <Image src={button.image} />}
          {Array.isArray(button.metadata) ? (
            button.metadata.map((metadata: string | { label: string; value: any }, index: number) => (
              <Text key={`context-metadata-${index}`}>
                {typeof metadata === 'string' ? `${metadata}` : `${metadata.label}: ${metadata.value}`}
              </Text>
            ))
          ) : (
            <>
              {typeof button.metadata === 'object' &&
                Object.entries(button.metadata).map((metadata: { [key: string]: any }, index) => (
                  <Text key={`context-metadata-${index}`}>
                    {metadata[0]}: {metadata[1]}
                  </Text>
                ))}
            </>
          )}
        </HoverCard.Dropdown>
      </HoverCard>
    </>
  );
};

export default ContextButton;

import { Button, createStyles, Group, HoverCard, Image, Progress, Stack, Text, useMantineTheme } from '@mantine/core';
import ReactMarkdown from 'react-markdown';
import { ContextMenuProps, Option } from '../../../../typings';
import { fetchNui } from '../../../../utils/fetchNui';
import { isIconUrl } from '../../../../utils/isIconUrl';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import MarkdownComponents from '../../../../config/MarkdownComponents';
import LibIcon from '../../../../components/LibIcon';
import { filterProps } from 'framer-motion';

const openMenu = (id: string | undefined) => {
  fetchNui<ContextMenuProps>('openContext', { id: id, back: false });
};

const clickContext = (id: string) => {
  fetchNui('clickContext', id);
};

const useStyles = createStyles((theme, params: { disabled?: boolean; readOnly?: boolean }) => ({
  inner: {
    justifyContent: 'flex-start',
  },
  label: {
    width: '100%',
    color: params.disabled ? theme.colors[theme.primaryColor][0] : theme.colors.dark[0],
    whiteSpace: 'pre-wrap',
    fontSize: 16,
    fontWeight: 400,
  },
  button: {
    height: 'fit-content',
    width: '100%',
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    opacity: params.disabled ? 1 : 1,
    padding: 10,
    '&:hover': {
      backgroundColor: params.readOnly ? 'rgba(0, 0, 0, 1)' : 'rgba(0, 0, 0, 1)',
      cursor: params.readOnly ? 'unset' : 'pointer',
    },
    '&:active': {
      transform: params.readOnly ? 'unset' : undefined,
    },
  },
  iconImage: {
    maxWidth: '25px',
  },
  description: {
    color: params.disabled ? theme.colors[theme.primaryColor][3] : theme.colors.dark[0],
    fontSize: 15,
    fontWeight: 300,
  },
  dropdown: {
    padding: 10,
    color: theme.colors.dark[0],
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    fontSize: 16,
    maxWidth: 256,
    width: 'fit-content',
    border: 'none',
  },
  buttonStack: {
    gap: 8,
    flex: '1',
  },
  buttonGroup: {
    gap: 8,
    flexWrap: 'nowrap',
  },
  buttonIconContainer: {
    minWidth: '45px',
    height: '45px',
    backgroundColor: 'rgba(0, 0, 0, 0.2)',
    borderRadius: theme.radius.sm,
    justifyContent: 'center',
    alignItems: 'center',
    color: params.disabled ? theme.colors[theme.primaryColor][theme.fn.primaryShade()] : theme.colors[theme.primaryColor][theme.fn.primaryShade()],
  },
  buttonTitleText: {
    overflowWrap: 'break-word',
    color: params.disabled ? theme.colors[theme.primaryColor][2] : '#fff',
  },
  buttonArrowContainer: {
    justifyContent: 'center',
    alignItems: 'center',
    padding: 0,
    width: 10,
    height: 25,
    color: 'white',
  },
  icon: {
    // filter: `drop-shadow(0 0 5px ${theme.colors[theme.primaryColor][theme.fn.primaryShade()]})`,
  }
}));

const ContextButton: React.FC<{
  option: [string, Option];
}> = ({ option }) => {
  const button = option[1];
  const buttonKey = option[0];
  const theme = useMantineTheme();

  const { classes } = useStyles({ disabled: button.disabled, readOnly: button.readOnly });

  return (
    <>
      <HoverCard
        position="right-start"
        disabled={button.disabled || !(button.metadata || button.image)}
        openDelay={200}
      >
        <HoverCard.Target>
          <Button
            classNames={{ inner: classes.inner, label: classes.label, root: classes.button }}
            onClick={() =>
              !button.disabled && !button.readOnly
                ? button.menu
                  ? openMenu(button.menu)
                  : clickContext(buttonKey)
                : null
            }
            variant="default"
            disabled={button.disabled}
          >
            <Group position="apart" w="100%" noWrap>
              <Stack className={classes.buttonStack}>
                {(button.title || Number.isNaN(+buttonKey)) && (
                  <Group className={classes.buttonGroup}>
                    {button?.icon && (
                      <Stack className={classes.buttonIconContainer}>
                        {typeof button.icon === 'string' && isIconUrl(button.icon) ? (
                          <img src={button.icon} className={classes.iconImage} alt="Missing img" />
                        ) : (
                          <LibIcon
                            className={classes.icon}
                            icon={button.icon as IconProp}
                            fixedWidth
                            size="lg"
                            style={{
                              color: button.iconColor,
                              filter: `drop-shadow(0 0 5px ${button.iconColor? button.iconColor : theme.colors[theme.primaryColor][theme.fn.primaryShade()]})`,
                            }}
                            animation={button.iconAnimation}
                          />
                        )}
                      </Stack>
                    )}
                    <div>
                    <Text className={classes.buttonTitleText}>
                      <ReactMarkdown components={MarkdownComponents}>{button.title || buttonKey}</ReactMarkdown>
                    </Text>
                    {button.description && (
                      <Text className={classes.description}>
                        <ReactMarkdown components={MarkdownComponents}>{button.description}</ReactMarkdown>
                      </Text>
                    )}
                    </div>
                  </Group>
                )}
                {button.progress !== undefined && (
                  <Progress value={button.progress} size="sm" color={button.colorScheme || 'dark.3'} />
                )}
              </Stack>
              {(button.menu || button.arrow) && button.arrow !== false && (
                <Stack className={classes.buttonArrowContainer}>
                  <LibIcon icon="chevron-right" fixedWidth />
                </Stack>
              )}
            </Group>
          </Button>
        </HoverCard.Target>
        <HoverCard.Dropdown className={classes.dropdown}>
          {button.image && <Image src={button.image} />}
          {Array.isArray(button.metadata) ? (
            button.metadata.map(
              (
                metadata: string | { label: string; value?: any; progress?: number; colorScheme?: string },
                index: number
              ) => (
                <>
                  <Text key={`context-metadata-${index}`}>
                    {typeof metadata === 'string' ? `${metadata}` : `${metadata.label}: ${metadata?.value ?? ''}`}
                  </Text>

                  {typeof metadata === 'object' && metadata.progress !== undefined && (
                    <Progress
                      value={metadata.progress}
                      size="sm"
                      color={metadata.colorScheme || button.colorScheme || 'dark.3'}
                    />
                  )}
                </>
              )
            )
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

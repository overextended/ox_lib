import { IconProp } from '@fortawesome/fontawesome-svg-core';
import { Button, createStyles, Group, HoverCard, Image, Progress, Stack, Text } from '@mantine/core';
import ReactMarkdown from 'react-markdown';
import LibIcon from '../../../../components/LibIcon';
import MarkdownComponents from '../../../../config/MarkdownComponents';
import { ContextMenuProps, Option } from '../../../../typings';
import { fetchNui } from '../../../../utils/fetchNui';
import { isIconUrl } from '../../../../utils/isIconUrl';

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
    whiteSpace: 'pre-wrap',
  },
  button: {
    backgroundColor: 'transparent',
    borderRadius: 0,
    height: 'fit-content',
    width: '100%',
    padding: 16,
    '&:hover': {
      cursor: params.readOnly ? 'unset' : 'pointer',
      backgroundColor: 'black',
      color: 'rgba(228, 0, 0, 0.5)',
    },
    '&:disabled': {
      backgroundColor: 'transparent',
      color: 'rgba(255, 255, 255, 0.5)',
    },
    '&:active': {
      transform: params.readOnly ? 'unset' : undefined,
    },
    transition: 'all 0.3s ease-in-out',
  },
  iconImage: {
    maxWidth: '25px',
  },
  dropdown: {
    padding: 16,
    color: '#FFFFFF',
    backgroundColor: 'rgba(0, 0, 0, 0.75)',
    fontSize: 14,
    fontWeight: 500,
    maxWidth: 256,
    width: 'fit-content',
    border: 'none',
    borderRadius: 16,
  },
  buttonStack: {
    gap: 4,
    flex: '1',
  },
  buttonGroup: {
    gap: 8,
    flexWrap: 'nowrap',
  },
  buttonIconContainer: {
    width: 25,
    height: 25,
    justifyContent: 'center',
    alignItems: 'center',
  },
  buttonTitleText: {
    overflowWrap: 'break-word',
    fontSize: 16,
    fontWeight: 600,
  },
  description: {
    fontSize: 14,
    color: 'rgba(255, 255, 255, 0.75)',
    fontWeight: 500,
    ':disabled': {
      color: 'rgba(255, 255, 255, 0.5)',
    },
  },
  buttonArrowContainer: {
    justifyContent: 'center',
    alignItems: 'center',
    width: 25,
    height: 25,
    color: 'rgba(228, 0, 0, 0.5)',
  },
  progress: {
    backgroundColor: 'rgba(255, 255, 255, 0.5)',
  },
}));

const ContextButton: React.FC<{
  option: [string, Option];
}> = ({ option }) => {
  const button = option[1];
  const buttonKey = option[0];
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
                            icon={button.icon as IconProp}
                            fixedWidth
                            size="lg"
                            style={{ color: button.iconColor }}
                            animation={button.iconAnimation}
                          />
                        )}
                      </Stack>
                    )}
                    <Text className={classes.buttonTitleText}>
                      <ReactMarkdown components={MarkdownComponents}>{button.title || buttonKey}</ReactMarkdown>
                    </Text>
                  </Group>
                )}
                {button.description && (
                  <Text className={classes.description}>
                    <ReactMarkdown components={MarkdownComponents}>{button.description}</ReactMarkdown>
                  </Text>
                )}
                {button.progress !== undefined && (
                  <Progress
                    value={button.progress}
                    size="md"
                    color={'rgba(228, 0, 0, 0.5)'}
                    bg={'rgba(255, 255, 255, 0.20)'}
                  />
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
                      size="md"
                      color={'rgba(228, 0, 0, 0.5)'}
                      bg={'rgba(255, 255, 255, 0.20)'}
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

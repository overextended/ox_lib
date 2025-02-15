import { IconProp } from '@fortawesome/fontawesome-svg-core';
import { Button, createStyles } from '@mantine/core';
import LibIcon from '../../../../components/LibIcon';

interface Props {
  icon: IconProp;
  canClose?: boolean;
  iconSize: number;
  handleClick: () => void;
}

const useStyles = createStyles((theme, params: { canClose?: boolean }) => ({
  button: {
    borderRadius: 32,
    flex: '1 15%',
    alignSelf: 'stretch',
    height: 'auto',
    textAlign: 'center',
    justifyContent: 'center',
    backgroundColor: 'transparent',
    '&:hover': {
      backgroundColor: 'black',
    },
    transition: 'all 0.3s ease-in-out',
  },
  root: {
    border: 'none',
  },
  label: {
    color: '#FFFFFF',
  },
}));

const HeaderButton: React.FC<Props> = ({ icon, canClose, iconSize, handleClick }) => {
  const { classes } = useStyles({ canClose });

  return (
    <Button
      variant="default"
      className={classes.button}
      classNames={{ label: classes.label, root: classes.root }}
      disabled={canClose === false}
      onClick={handleClick}
      styles={{
        root: {
          backgroundColor: 'transparent',
          ':hover': { backgroundColor: 'black' },
        },
      }}
    >
      <LibIcon icon={icon} fontSize={iconSize} fixedWidth />
    </Button>
  );
};

export default HeaderButton;

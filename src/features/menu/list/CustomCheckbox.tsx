import { Checkbox, createStyles } from '@mantine/core';

const useStyles = createStyles((theme) => ({
  root: {
    display: 'flex',
    alignItems: 'center',
  },
  input: {
    backgroundColor: 'rgba(0, 0, 0, 0.75)',
    '&:checked': { backgroundColor: 'rgba(255, 255, 255, 0.75)', borderColor: theme.colors.dark[2] },
  },
  inner: {
    '> svg > path': {
      fill: theme.colors.dark[6],
    },
  },
}));

const CustomCheckbox: React.FC<{ checked: boolean }> = ({ checked }) => {
  const { classes } = useStyles();
  return (
    <Checkbox
      checked={checked}
      size="md"
      classNames={{ root: classes.root, input: classes.input, inner: classes.inner }}
    />
  );
};

export default CustomCheckbox;

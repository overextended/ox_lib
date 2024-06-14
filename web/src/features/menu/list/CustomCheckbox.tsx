import { Checkbox, createStyles } from '@mantine/core';

const useStyles = createStyles((theme) => ({
  root: {
    display: 'flex',
    alignItems: 'center',
  },
  input: {
    backgroundColor: theme.colors.dark[1],
    '&:checked': { backgroundColor: theme.colors.dark[0], borderColor: theme.colors.dark[9] },
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

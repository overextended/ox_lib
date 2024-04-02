import { useState } from 'react';
import { Box, createStyles } from '@mantine/core';
import ScaleFade from '../../transitions/ScaleFade';

const useStyles = createStyles((theme) => ({
  container: {
    width: '100%',
    height: 5,
		marginTop: 7,
    borderRadius: theme.radius.sm,
    backgroundColor: theme.colors.dark[5],
    overflow: 'hidden',
  },
  bar: {
    height: '100%',
    backgroundColor: theme.colors[theme.primaryColor][theme.fn.primaryShade()],
  },
}));

const ShowDurationBar: React.FC<{ duration: number; marginTop?: number; height?: number }> = ({
	duration,
  marginTop,
  height
}) => {
  const { classes } = useStyles();
	const [visible, setVisible] = useState(true);

  return (
    <>
      <ScaleFade visible={visible}>
        <Box
          className={classes.container}
          sx={{
            height: height || 5,
            marginTop: marginTop || 7,
          }}
        >
          <Box
            className={classes.bar}
            onAnimationEnd={() => setVisible(false)}
            sx={{
              animation: 'progress-bar linear',
              animationDirection: 'reverse',
              animationFillMode: 'forwards',
              animationDuration: `${duration}ms`
            }}
          >
          </Box>
        </Box>
      </ScaleFade>
    </>
  );
};

export default ShowDurationBar;
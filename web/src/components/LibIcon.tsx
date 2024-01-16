import { FontAwesomeIcon, FontAwesomeIconProps } from '@fortawesome/react-fontawesome';

export type IconAnimation =
  | 'spin'
  | 'spinPulse'
  | 'spinReverse'
  | 'pulse'
  | 'beat'
  | 'fade'
  | 'beatFade'
  | 'bounce'
  | 'shake';

const LibIcon: React.FC<FontAwesomeIconProps & { animation?: IconAnimation }> = (props) => {
  const animationProps = {
    spin: props.animation === 'spin',
    spinPulse: props.animation === 'spinPulse',
    spinReverse: props.animation === 'spinReverse',
    pulse: props.animation === 'pulse',
    beat: props.animation === 'beat',
    fade: props.animation === 'fade',
    beatFade: props.animation === 'beatFade',
    bounce: props.animation === 'bounce',
    shake: props.animation === 'shake',
  };

  return <FontAwesomeIcon {...props} {...animationProps} />;
};

export default LibIcon;

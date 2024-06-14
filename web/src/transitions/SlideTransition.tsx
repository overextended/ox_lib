import { AnimatePresence, motion } from 'framer-motion';

const SlideTransition: React.FC<{ 
  visible: boolean; 
  children: React.ReactNode; 
  position: 'left' | 'right'; 
  onExitComplete?: () => void 
}> = ({ visible, children, position, onExitComplete }) => {

  // Definir os valores de animação com base na posição
  const animations = {
    left: {
      initial: { transform: 'translateX(0%)', opacity: 0 },
      animate: { transform: 'translateX(0%)', opacity: 1, transition: { duration: 0.5, ease: [0, 0, 0.2, 1] } },
      exit: { transform: 'translateX(0%)', opacity: 0, transition: { duration: 0.5, ease: [0.4, 0, 1, 1] } }
    },
    right: {
      initial: { transform: 'translateX(0%)', opacity: 0 },
      animate: { transform: 'translateX(0%)', opacity: 1, transition: { duration: 0.5, ease: [0, 0, 0.2, 1] } },
      exit: { transform: 'translateX(0%)', opacity: 0, transition: { duration: 0.5, ease: [0.4, 0, 1, 1] } }
    }
  };

  const currentAnimation = animations[position];

  return (
    <AnimatePresence onExitComplete={onExitComplete}>
      {visible && (
        <motion.div
          initial={currentAnimation.initial}
          animate={currentAnimation.animate}
          exit={currentAnimation.exit}
        >
          {children}
        </motion.div>
      )}
    </AnimatePresence>
  );
};

export default SlideTransition;

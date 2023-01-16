import { ActionIcon, Box, Tooltip } from '@mantine/core';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { IconProp } from '@fortawesome/fontawesome-svg-core';

const radius = 60;

// https://codesandbox.io/embed/circular-menu-e94ug
function getTransform(index: number, totalItems: number) {
  const value = index / totalItems;

  const x = radius * Math.cos(Math.PI * 2 * (value - 0.25));
  const y = radius * Math.sin(Math.PI * 2 * (value - 0.25));

  return `translate(${x}px, ${y}px)`;
}

const items: { icon: IconProp; label: string }[] = [
  { icon: 'handcuffs', label: 'Arrest' },
  { icon: 'warehouse', label: 'Garage' },
  { icon: 'heart', label: 'Info' },
  { icon: 'handcuffs', label: 'Arrest' },
  { icon: 'warehouse', label: 'Garage' },
  { icon: 'heart', label: 'Info' },
];

const PlanetMenu: React.FC = () => {
  return (
    <Box
      style={{
        position: 'absolute',
        top: '50%',
        left: '50%',
        transform: 'translate(-50%, -50%)',
      }}
    >
      <ActionIcon variant="filled" radius="xl" size="xl" color="primary" sx={{ zIndex: 99 }} w={50} h={50}>
        <FontAwesomeIcon fixedWidth icon="xmark" size="lg" />
      </ActionIcon>
      <Box
        sx={{
          position: 'absolute',
          top: '50%',
          left: '50%',
          transform: 'translate(-50%, -50%)',
          width: 120,
          height: 120,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        {items.map((item, index) => (
          <Box
            sx={(theme) => ({
              transform: getTransform(index, items.length),
              position: 'absolute',
              width: 40,
              height: 40,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              borderRadius: '50%',
              backgroundColor: theme.colors.dark[6],
              color: theme.colors.dark[0],
              boxShadow: theme.shadows.sm,
              padding: 12,
              '&:hover': {
                backgroundColor: theme.colors.dark[5],
                cursor: 'pointer',
              },
            })}
          >
            <FontAwesomeIcon icon={item.icon} fixedWidth />
          </Box>
        ))}
      </Box>
    </Box>
  );
};

export default PlanetMenu;

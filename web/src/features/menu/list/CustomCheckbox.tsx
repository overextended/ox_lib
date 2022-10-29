import { Box, Flex, useCheckbox, chakra, CheckboxIcon } from '@chakra-ui/react';

const CustomCheckbox: React.FC<{ checked: boolean }> = ({ checked }) => {
  const { getCheckboxProps, getInputProps, htmlProps } = useCheckbox();
  return (
    <chakra.label
      display="flex"
      flexDirection="row"
      alignItems="center"
      gridColumnGap={2}
      pr={3}
      cursor="pointer"
      {...htmlProps}
    >
      <input {...getInputProps()} hidden />
      <Flex
        alignItems="center"
        justifyContent="center"
        border="2px solid"
        borderColor="#909296"
        rounded={'sm'}
        w={5}
        h={5}
        {...getCheckboxProps()}
      >
        {checked && (
          <Box w={4} h={4} bg="#909296">
            <CheckboxIcon isChecked color="#25262B" />
          </Box>
        )}
      </Flex>
    </chakra.label>
  );
};

export default CustomCheckbox;

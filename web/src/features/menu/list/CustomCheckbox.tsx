import { Box, Flex, useCheckbox, chakra, CheckboxIcon } from '@chakra-ui/react';

const CustomCheckbox: React.FC<{ checked: boolean }> = ({ checked }) => {
  const { getCheckboxProps, getInputProps, htmlProps } = useCheckbox();
  return (
    <chakra.label
      display='flex'
      flexDirection='row'
      alignItems='center'
      gridColumnGap={2}
      pr={4}
      cursor='pointer'
      {...htmlProps}
    >
      <input {...getInputProps()} hidden />
      <Flex
        alignItems='center'
        justifyContent='center'
        border='2px solid'
        borderColor='#909296'
        rounded={'sm'}
        w={6}
        h={6}
        {...getCheckboxProps()}
      >
        {checked && (
          <Box w={5} h={5} bg='#25262B'>
            <CheckboxIcon isChecked color={'#373A40'} />
          </Box>
        )}
      </Flex>
    </chakra.label>
  )
};

export default CustomCheckbox;

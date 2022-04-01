import { extendTheme, type ThemeConfig } from "@chakra-ui/react";

const config: ThemeConfig = {
    initialColorMode: 'dark',
    useSystemColorMode: false
}

export const theme = extendTheme({
    config,
    components: {
        Progress: {
          baseStyle: {
            filledTrack: {
              bg: 'green.400'
            },
            track: {
              bg: 'rgba(0, 0, 0, 0.6)'
            }
          }
        },
    }
})
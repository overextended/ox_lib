import React from "react";
import ReactDOM from "react-dom";
import "./index.css";
import App from "./App";
import { VisibilityProvider } from "./providers/VisibilityProvider";
import { ChakraProvider } from "@chakra-ui/react";
import { theme } from "./theme";
import { debugData } from "./utils/debugData";
import { fas } from "@fortawesome/free-solid-svg-icons";
import { far } from "@fortawesome/free-regular-svg-icons";
import { fab } from "@fortawesome/free-brands-svg-icons";
import { library } from "@fortawesome/fontawesome-svg-core";
import { isEnvBrowser } from "./utils/misc";
import LocaleProvider from "./providers/LocaleProvider";

library.add(fas, far, fab);

if (isEnvBrowser()) {
  const root = document.getElementById("root");

  // https://i.imgur.com/iPTAdYV.png - Night time img
  root!.style.backgroundImage = 'url("https://i.imgur.com/3pzRj9n.png")';
  root!.style.backgroundSize = "cover";
  root!.style.backgroundRepeat = "no-repeat";
  root!.style.backgroundPosition = "center";
}

debugData([
  {
    action: "setVisible",
    data: true,
  },
]);

ReactDOM.render(
  <React.StrictMode>
    <LocaleProvider>
      <VisibilityProvider>
        <ChakraProvider theme={theme}>
          <App />
        </ChakraProvider>
      </VisibilityProvider>
    </LocaleProvider>
  </React.StrictMode>,
  document.getElementById("root")
);

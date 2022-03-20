import React from "react";
import ReactDOM from "react-dom";
import "./index.css";
import App from "./components/App";
import { VisibilityProvider } from "./providers/VisibilityProvider";
import { ChakraProvider } from "@chakra-ui/react";
import { theme } from "./theme";
import { debugData } from "./utils/debugData";
import { fas } from "@fortawesome/free-solid-svg-icons";
import { far } from "@fortawesome/free-regular-svg-icons";
import { fab } from "@fortawesome/free-brands-svg-icons";
import { library } from "@fortawesome/fontawesome-svg-core";

library.add(fas, far, fab);

debugData([
  {
    action: "setVisible",
    data: true,
  },
]);

ReactDOM.render(
  <React.StrictMode>
    <VisibilityProvider>
      <ChakraProvider theme={theme}>
        <App />
      </ChakraProvider>
    </VisibilityProvider>
  </React.StrictMode>,
  document.getElementById("root")
);

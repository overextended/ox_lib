import Notifications from "./Notifications";
import CircleProgressbar from "./CircleProgressbar";
import { CircularProgress } from "@chakra-ui/react";

const App: React.FC = () => {
  return (
    <>
      <CircleProgressbar />
      <Notifications />
    </>
  );
};

export default App;

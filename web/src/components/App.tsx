import Notifications from "./Notifications";
import CircleProgressbar from "./CircleProgressbar";
import Progressbar from "./Progressbar";
import TextUI from "./TextUI";

const App: React.FC = () => {
  return (
    <>
      <Progressbar />
      <CircleProgressbar />
      <Notifications />
      <TextUI />
    </>
  );
};

export default App;

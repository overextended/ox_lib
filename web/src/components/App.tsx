import Notifications from "./Notifications";
import CircleProgressbar from "./CircleProgressbar";
import Progressbar from "./Progressbar";

const App: React.FC = () => {
  return (
    <>
      <Progressbar />
      <CircleProgressbar />
      <Notifications />
    </>
  );
};

export default App;

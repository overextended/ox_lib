import { useToast, type ToastPositionWithLogical, Box } from "@chakra-ui/react";
import { useNuiEvent } from "../hooks/useNuiEvent";
import { debugData } from "../utils/debugData";
import { IconProp } from "@fortawesome/fontawesome-svg-core";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";

interface Props {
  title?: string;
  description: string;
  duration?: number;
  position?: ToastPositionWithLogical;
  status?: "info" | "warning" | "success" | "error";
  color?: string;
  icon?: string;
  id?: number;
}

interface CustomProps {
  style?: React.CSSProperties;
  text: string;
  duration?: number;
  icon?: IconProp;
  position?: ToastPositionWithLogical;
  id?: number;
}

debugData<Props>([
  {
    action: "notify",
    data: {
      description: "Dunak is nerd",
      color: "red",
      id: 1,
    },
  },
]);

debugData<CustomProps>([
  {
    action: "customNotify",
    data: {
      text: "Dunak is nerd",
      icon: "clipboard-check",
      style: {
        backgroundColor: "#2D3748",
        color: "white",
      },
    },
  },
]);

const Notifications: React.FC = () => {
  const toast = useToast();

  // todo: figure out icon support
  useNuiEvent<CustomProps>("customNotify", (data) => {
    if (data.id && toast.isActive(data.id)) return;
    toast({
      duration: data.duration || 4000,
      position: data.position || "top-right",
      render: () => (
        <Box style={data.style} p={3}>
          {data.icon && <FontAwesomeIcon icon={data.icon} />}
          {data.text}
        </Box>
      ),
    });
  });

  useNuiEvent<Props>("notify", (data) => {
    if (data.id && toast.isActive(data.id)) return;
    toast({
      title: data.title,
      description: data.description,
      duration: data.duration || 4000,
      position: data.position || "top-right",
      status: data.status,
    });
  });

  return <></>;
};

export default Notifications;

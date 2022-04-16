import {
  useToast,
  type ToastPositionWithLogical,
  Box,
  HStack,
  Text,
} from "@chakra-ui/react";
import { useNuiEvent } from "../../hooks/useNuiEvent";
import { debugData } from "../../utils/debugData";
import { IconProp } from "@fortawesome/fontawesome-svg-core";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";

interface Props {
  title?: string;
  description?: string;
  duration?: number;
  position?: ToastPositionWithLogical;
  status?: "info" | "warning" | "success" | "error";
  id?: number;
}

interface CustomProps {
  style?: React.CSSProperties;
  description?: string;
  title?: string;
  duration?: number;
  icon?: IconProp;
  iconColor?: string;
  position?: ToastPositionWithLogical;
  id?: number;
  type?: string;
}

debugData<Props>([
  {
    action: "notify",
    data: {
      description: "Dunak is nerd",
      title: "Dunak",
      id: 1,
    },
  },
]);

debugData<CustomProps>([
  {
    action: "customNotify",
    data: {
      description: "Dunak is nerd",
      icon: "basket-shopping",
      style: {
        backgroundColor: "#2D3748",
        color: "white",
      },
    },
  },
]);

const Notifications: React.FC = () => {
  const toast = useToast();

  useNuiEvent<CustomProps>("customNotify", (data) => {
    if (!data.title && !data.description) return;
    if (data.id && toast.isActive(data.id)) return;
    if (!data.icon) {
      data.icon =
        data.type === "error"
          ? "circle-xmark"
          : data.type === "success"
          ? "circle-check"
          : "circle-info";
    }

    toast({
      duration: data.duration || 3000,
      position: data.position || "top-right",
      render: () => (
        <Box
          className={`toast-${data.type || "inform"}`}
          style={data.style}
          p={2}
          borderRadius="sm"
          boxShadow="md"
        >
          <HStack spacing={0}>
            {data.icon && (
              <FontAwesomeIcon
                fixedWidth
                icon={data.icon}
                fontSize="1.3em"
                style={{ paddingRight: 8 }}
                color={data.iconColor}
              />
            )}
            <Box w="100%">
              {data.title && <Text as="b">{data.title}</Text>}
              {data.description && <Text>{data.description}</Text>}
            </Box>
          </HStack>
        </Box>
      ),
    });
  });

  useNuiEvent<Props>("notify", (data) => {
    if (!data.title && !data.description) return;
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

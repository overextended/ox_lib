import {
  useToast,
  type ToastPositionWithLogical,
  Box,
  HStack,
  Text,
} from "@chakra-ui/react";
import { useNuiEvent } from "../../hooks/useNuiEvent";
import { IconProp } from "@fortawesome/fontawesome-svg-core";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";

export interface NotificationProps {
  title?: string;
  description?: string;
  duration?: number;
  position?: ToastPositionWithLogical;
  status?: "info" | "warning" | "success" | "error";
  id?: number;
}

export interface CustomNotificationProps {
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

const Notifications: React.FC = () => {
  const toast = useToast();

  useNuiEvent<CustomNotificationProps>("customNotify", (data) => {
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

    const id = data.id;
    toast({
      id,
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

  useNuiEvent<NotificationProps>("notify", (data) => {
    if (!data.title && !data.description) return;
    if (data.id && toast.isActive(data.id)) return;
    const id = data.id;
    toast({
      id,
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

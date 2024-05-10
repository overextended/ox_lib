import { ButtonVariant } from "@mantine/core";

export interface AlertProps {
  header: string;
  content: string;
  centered?: boolean;
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl';
  overflow?: boolean;
  confirm?: boolean;
  cancel?: boolean;
  labels?: {
    cancel?: string;
    confirm?: string;
  };
  actions?: {
    id: string;
    label: string;
    variant?: ButtonVariant;
  }[];
}

export interface AlertProps {
  header: string;
  content: string;
  centered?: boolean;
  timeout?: number;
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl';
  overflow?: boolean;
  cancel?: boolean;
  confirm?: boolean;
  labels?: {
    cancel?: string;
    confirm?: string;
  };
}

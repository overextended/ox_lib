
export interface CircleProgressbarProps {
  label?: string;
  duration: number;
  position?: 'middle' | 'bottom';
  icon?: string;
  iconColor?: string;
  percent?: boolean;
}

export interface ProgressbarProps {
  label: string;
  duration: number;
}

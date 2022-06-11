export interface Option {
  menu?: string;
  title?: string;
  description?: string;
  arrow?: boolean;
  image?: string;
  metadata?:
    | string[]
    | { [key: string]: any }
    | { label: string; value: any }[];
  event?: string;
  serverEvent?: string;
  args?: any;
}

export interface Options {
  [key: string]: Option;
}

export interface ContextMenuProps {
  title: string;
  menu?: string;
  options: Options | Option[];
}

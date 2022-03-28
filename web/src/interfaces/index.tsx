export interface Option {
  menu?: string;
  description?: string;
  metadata?: string[] | { [key: string]: any };
}

export interface Options {
  [key: string]: Option;
}

export interface ContextMenuProps {
  title: string;
  menu?: string;
  options: Options;
}

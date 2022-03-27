export interface Option {
  description?: string;
  metadata?: string[] | { [key: string]: any };
  subMenu?: boolean;
}

export interface Options {
  [key: string]: Option;
}

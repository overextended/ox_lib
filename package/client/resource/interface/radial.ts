import { IconName, IconPrefix } from '@fortawesome/fontawesome-common-types';

type RadialItem = {
  id: string;
  label: string;
  icon: IconName | [IconPrefix, IconName];
  onSelect?: () => void;
  menu?: string;
};

export const addRadialItem = (items: RadialItem | RadialItem[]) => exports.ox_lib.addRadialItem(items);

export const removeRadialItem = (item: string) => exports.ox_lib.removeRadialItem(item);

export const registerRadial = (radial: { id: string; items: Omit<RadialItem, 'id'>[] }) =>
  exports.ox_lib.registerRadial(radial);

export const hideRadial = () => exports.ox_lib.hideRadial();

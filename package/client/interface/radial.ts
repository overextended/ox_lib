import type { IconName, IconPrefix } from '@fortawesome/fontawesome-common-types';

type RadialItem = {
  id: string;
  label: string;
  icon: IconName | [IconPrefix, IconName];
  onSelect?: (currentMenu: string | null, itemIndex: number) => void | string;
  menu?: string;
  iconWidth?: number;
  iconHeight?: number;
};

/** Adds or replaces items in the global radial menu or the specified submenu. */
export const addRadialItem = (items: RadialItem | RadialItem[], parentMenuId?: string) => exports.ox_lib.addRadialItem(items, parentMenuId);

/** Removes an item by id from the global radial menu or the specified submenu. */
export const removeRadialItem = (item: string, parentMenuId?: string) => exports.ox_lib.removeRadialItem(item, parentMenuId);

/** Registers a radial submenu by id. */
export const registerRadial = (radial: { id: string; items: Omit<RadialItem, 'id'>[] }) =>
  exports.ox_lib.registerRadial(radial);

/** Returns the id of the current radial submenu, if any. */
export const getCurrentRadialId = () => exports.ox_lib.getCurrentRadialId();

/** Opens the radial menu with the given id. */
export const showRadialMenu = (menuId: string) => exports.ox_lib.showRadialMenu(menuId);

/** Closes the radial menu and clears its navigation history. */
export const hideRadial = () => exports.ox_lib.hideRadial();

/** Sets whether the player can open the radial menu. */
export const disableRadial = (state: boolean) => exports.ox_lib.disableRadial(state);

type aceFunction = (principal: string | number, ace: string, allow: boolean) => void;
type principalFunction = (child: string, parent: string) => void;

/** Adds an allow or deny ACE for a principal through ox_lib. */
export const addAce: aceFunction = (principal, ace, allow) => exports.ox_lib.addAce(principal, ace, allow);
/** Removes an allow or deny ACE from a principal through ox_lib. */
export const removeAce: aceFunction = (principal, ace, allow) => exports.ox_lib.removeAce(principal, ace, allow);

/** Makes a child principal inherit the parent principal's permissions. */
export const addPrincipal: principalFunction = (child, parent) => exports.ox_lib.addPrincipal(child, parent);
/** Removes a child principal's inheritance from a parent principal. */
export const removePrincipal: principalFunction = (child, parent) => exports.ox_lib.removePrincipal(child, parent);

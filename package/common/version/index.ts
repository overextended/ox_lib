/** Checks a resource's version metadata against the required minimum through ox_lib. */
export const checkDependency = (resource: string, minimumVersion: string, printMessage?: boolean) =>
  exports.ox_lib.checkDependency(resource, minimumVersion, printMessage);

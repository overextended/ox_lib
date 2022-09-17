export const requestAnimDict = (animDict: string, timeout?: number): string =>
  exports.ox_lib.requestAnimDict(animDict, timeout);

export const requestAnimSet = (animSet: string, timeout?: number): string =>
  exports.ox_lib.requestAnimSet(animSet, timeout);

export const requestModel = (model: string | number, timeout?: number): string =>
  exports.ox_lib.requestModel(model, timeout);

export const requestStreamedTextureDict = (dict: string, timeout?: number): string =>
  exports.ox_lib.requestStreamedTextureDict(dict, timeout);

export const requestNamedPtfxAsset = (fxName: string, timeout?: number): string =>
  exports.ox_lib.requestNamedPtfxAsset(fxName, timeout);

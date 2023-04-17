function streamingRequest(
  request: Function,
  hasLoaded: Function,
  assetType: string,
  asset: any,
  timeout?: number,
  ...args: any
): Promise<any> {
  return new Promise((resolve, reject) => {
    if (hasLoaded(asset)) resolve(asset);

    request(asset, ...args);

    if (typeof timeout !== 'number') timeout = 500;

    let i = 0;

    setTick(() => {
      if (hasLoaded(asset)) resolve(asset);

      i++;

      if (i === timeout) reject(`failed to load ${assetType} '${asset}' after ${timeout} ticks`);
    });
  });
}

export const requestAnimDict = (animDict: string, timeout?: number): Promise<string> => {
  if (!DoesAnimDictExist(animDict)) throw new Error(`attempted to load invalid animDict '${animDict}'`);

  return streamingRequest(RequestAnimDict, HasAnimDictLoaded, 'animDict', animDict, timeout);
};

export const requestAnimSet = (animSet: string, timeout?: number): Promise<string> =>
  streamingRequest(RequestAnimSet, HasAnimSetLoaded, 'animSet', animSet, timeout);

export const requestModel = (model: string | number, timeout?: number): Promise<number> => {
  if (typeof model !== 'number') model = GetHashKey(model);
  if (!IsModelValid(model)) throw new Error(`attempted to load invalid model '${model}'`);

  return streamingRequest(RequestModel, HasModelLoaded, 'model', model, timeout);
};

export const requestStreamedTextureDict = (textureDict: string, timeout?: number): Promise<string> =>
  streamingRequest(RequestStreamedTextureDict, HasStreamedTextureDictLoaded, 'textureDict', textureDict, timeout);

export const requestNamedPtfxAsset = (ptFxName: string, timeout?: number): Promise<string> =>
  streamingRequest(RequestNamedPtfxAsset, HasNamedPtfxAssetLoaded, 'ptFxName', ptFxName, timeout);

export const requestWeaponAsset = (weaponHash: string | number, timeout?: number, weaponResourceFlags: number = 31, extraWeaponComponentFlags: number = 0): Promise<string | number> => {
  return streamingRequest(RequestWeaponAsset, HasWeaponAssetLoaded, 'weaponHash', weaponHash, timeout, weaponResourceFlags, extraWeaponComponentFlags);
}

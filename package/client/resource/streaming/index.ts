import { waitFor } from '../../';

function streamingRequest<T extends string | number>(
  request: Function,
  hasLoaded: Function,
  assetType: string,
  asset: T,
  timeout: number = 1000,
  ...args: any
) {
  if (hasLoaded(asset)) return asset;

  request(asset, ...args);

  return waitFor(
    () => {
      if (hasLoaded(asset)) return asset;
    },
    `failed to load ${assetType} '${asset}'`,
    timeout
  );
}

export const requestAnimDict = (animDict: string, timeout?: number) => {
  if (!DoesAnimDictExist(animDict)) throw new Error(`attempted to load invalid animDict '${animDict}'`);

  return streamingRequest(RequestAnimDict, HasAnimDictLoaded, 'animDict', animDict, timeout);
};

export const requestAnimSet = (animSet: string, timeout?: number) =>
  streamingRequest(RequestAnimSet, HasAnimSetLoaded, 'animSet', animSet, timeout);

export const requestModel = (model: string | number, timeout?: number) => {
  if (typeof model !== 'number') model = GetHashKey(model);
  if (!IsModelValid(model)) throw new Error(`attempted to load invalid model '${model}'`);

  return streamingRequest(RequestModel, HasModelLoaded, 'model', model, timeout);
};

export const requestNamedPtfxAsset = (ptFxName: string, timeout?: number) =>
  streamingRequest(RequestNamedPtfxAsset, HasNamedPtfxAssetLoaded, 'ptFxName', ptFxName, timeout);

export const requestScaleformMovie = (scaleformName: string, timeout?: number) =>
  streamingRequest(RequestScaleformMovie, HasScaleformMovieLoaded, 'scaleformMovie', scaleformName, timeout);

export const requestStreamedTextureDict = (textureDict: string, timeout?: number) =>
  streamingRequest(RequestStreamedTextureDict, HasStreamedTextureDictLoaded, 'textureDict', textureDict, timeout);

export const requestWeaponAsset = (
  weaponHash: string | number,
  timeout?: number,
  weaponResourceFlags: number = 31,
  extraWeaponComponentFlags: number = 0
) =>
  streamingRequest(
    RequestWeaponAsset,
    HasWeaponAssetLoaded,
    'weaponHash',
    weaponHash,
    timeout,
    weaponResourceFlags,
    extraWeaponComponentFlags
  );

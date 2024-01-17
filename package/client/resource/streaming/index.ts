import { waitFor } from '../../';

async function streamingRequest(
  request: Function,
  hasLoaded: Function,
  assetType: string,
  asset: any,
  timeout?: number,
  ...args: any
): Promise<any> {
  if (hasLoaded(asset)) return asset;

  request(asset, ...args);

  waitFor(
    () => {
      if (hasLoaded(asset)) return asset;
    },
    `failed to load ${assetType} '${asset}' after ${timeout} ticks`,
    timeout || 500
  );
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

export const requestNamedPtfxAsset = (ptFxName: string, timeout?: number): Promise<string> =>
  streamingRequest(RequestNamedPtfxAsset, HasNamedPtfxAssetLoaded, 'ptFxName', ptFxName, timeout);

export const requestScaleformMovie = (scaleformName: string, timeout?: number): Promise<string> =>
  streamingRequest(RequestScaleformMovie, HasScaleformMovieLoaded, 'scaleformMovie', scaleformName, timeout);

export const requestStreamedTextureDict = (textureDict: string, timeout?: number): Promise<string> =>
  streamingRequest(RequestStreamedTextureDict, HasStreamedTextureDictLoaded, 'textureDict', textureDict, timeout);

export const requestWeaponAsset = (
  weaponHash: string | number,
  timeout?: number,
  weaponResourceFlags: number = 31,
  extraWeaponComponentFlags: number = 0
): Promise<string | number> =>
  streamingRequest(
    RequestWeaponAsset,
    HasWeaponAssetLoaded,
    'weaponHash',
    weaponHash,
    timeout,
    weaponResourceFlags,
    extraWeaponComponentFlags
  );

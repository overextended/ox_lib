import { waitFor } from '..';

/** Requests an asset and returns it once loaded, rejecting after the timeout in milliseconds. */
function streamingRequest<T extends string | number>(
  request: Function,
  hasLoaded: Function,
  assetType: string,
  asset: T,
  timeout: number = 30000,
  ...args: any
) {
  if (hasLoaded(asset)) return asset;

  request(asset, ...args);

  return (waitFor(() => {
    if (hasLoaded(asset)) return asset;
  }, timeout) as Promise<T>).catch((err) => {
    throw new Error(`failed to load ${assetType} '${asset}' - ${err}.`)
  });
}

/** Loads an animation dictionary, rejecting on timeout and throwing for an invalid dictionary. */
export const requestAnimDict = (animDict: string, timeout?: number) => {
  if (!DoesAnimDictExist(animDict)) throw new Error(`attempted to load invalid animDict '${animDict}'`);

  return streamingRequest(RequestAnimDict, HasAnimDictLoaded, 'animDict', animDict, timeout);
};

/** Loads an animation set with an optional timeout in milliseconds. */
export const requestAnimSet = (animSet: string, timeout?: number) =>
  streamingRequest(RequestAnimSet, HasAnimSetLoaded, 'animSet', animSet, timeout);

/** Loads a model by name or hash, throwing for invalid models and rejecting on timeout. */
export const requestModel = (model: string | number, timeout?: number) => {
  if (typeof model !== 'number') model = GetHashKey(model);
  if (!IsModelValid(model)) throw new Error(`attempted to load invalid model '${model}'`);

  return streamingRequest(RequestModel, HasModelLoaded, 'model', model, timeout);
};

/** Loads a named particle effect asset with an optional timeout in milliseconds. */
export const requestNamedPtfxAsset = (ptFxName: string, timeout?: number) =>
  streamingRequest(RequestNamedPtfxAsset, HasNamedPtfxAssetLoaded, 'ptFxName', ptFxName, timeout);

/** Loads a Scaleform movie and returns its handle, rejecting after the timeout in milliseconds. */
export const requestScaleformMovie = (scaleformName: string, timeout = 30000) => {
  const handle = RequestScaleformMovie(scaleformName);

  if (HasScaleformMovieLoaded(handle)) return handle;

  return waitFor(() => {
    if (HasScaleformMovieLoaded(handle)) return handle;
  }, timeout).catch((err) => {
    throw new Error(`failed to load scaleformMovie '${scaleformName}' - ${err}.`);
  });
};

/** Loads a streamed texture dictionary with an optional timeout in milliseconds. */
export const requestStreamedTextureDict = (textureDict: string, timeout?: number) =>
  streamingRequest(RequestStreamedTextureDict, HasStreamedTextureDictLoaded, 'textureDict', textureDict, timeout);

/** Loads a weapon asset using the supplied resource and component flags. */
export const requestWeaponAsset = (
  weaponHash: string | number,
  timeout?: number,
  weaponResourceFlags: number = 31,
  extraWeaponComponentFlags: number = 0,
) =>
  streamingRequest(
    RequestWeaponAsset,
    HasWeaponAssetLoaded,
    'weaponHash',
    weaponHash,
    timeout,
    weaponResourceFlags,
    extraWeaponComponentFlags,
  );

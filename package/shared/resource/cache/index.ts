export const cache: Record<string, any> = new Proxy(
  {
    resource: GetCurrentResourceName(),
  },
  {
    get(target, key: string) {
      let result = key ? target[key] : target;
      if (result) return result;

      AddEventHandler(`ox_lib:cache:${key}`, (value: any) => {
        target[key] = value;
      });

      target[key] = exports.ox_lib.cache(key);
      return target[key];
    },
  }
);

export const onCache = (key: string, cb: (value: any) => void) => {
  AddEventHandler(`ox_lib:cache:${key}`, cb);
};

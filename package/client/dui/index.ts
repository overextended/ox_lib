import { cache } from '../cache';

const duis: Record<string, Dui> = {};
let currentId = 0;

interface DuiProperties {
  url: string;
  width: number;
  height: number;
  debug?: boolean;
}

export class Dui {
  private id: string = '';
  private debug: boolean = false;
  url: string = '';
  duiObject: number = 0;
  duiHandle: string = '';
  runtimeTxd: number = 0;
  txdObject: number = 0;
  dictName: string = '';
  txtName: string = '';

  constructor(data: DuiProperties) {
    const time = GetGameTimer();
    const id = `${cache.resource}_${time}_${currentId}`;
    currentId++;
    this.id = id;
    this.debug = data.debug || false;
    this.url = data.url;
    this.dictName = `ox_lib_dui_dict_${id}`;
    this.txtName = `ox_lib_dui_txt_${id}`;
    this.duiObject = CreateDui(data.url, data.width, data.height);
    this.duiHandle = GetDuiHandle(this.duiObject);
    this.runtimeTxd = CreateRuntimeTxd(this.dictName);
    this.txdObject = CreateRuntimeTextureFromDuiHandle(this.runtimeTxd, this.txtName, this.duiHandle);
    duis[id] = this;

    if (this.debug) console.log(`Dui ${this.id} created`);
  }

  remove() {
    SetDuiUrl(this.duiObject, 'about:blank');
    DestroyDui(this.duiObject);
    delete duis[this.id];

    if (this.debug) console.log(`Dui ${this.id} removed`);
  }

  setUrl(url: string) {
    this.url = url;
    SetDuiUrl(this.duiObject, url);

    if (this.debug) console.log(`Dui ${this.id} url set to ${url}`);
  }

  sendMessage(data: object) {
    SendDuiMessage(this.duiObject, JSON.stringify(data));

    if (this.debug) console.log(`Dui ${this.id} message sent with data :`, data);
  }
}

on('onResourceStop', (resourceName: string) => {
  if (cache.resource !== resourceName) return;

  for (const dui in duis) {
    duis[dui].remove();
  }
});

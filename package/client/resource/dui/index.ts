import {
  GetGameTimer,
  GetCurrentResourceName,
  CreateDui,
  GetDuiHandle,
  CreateRuntimeTxd,
  CreateRuntimeTextureFromDuiHandle,
  SetDuiUrl,
  DestroyDui,
  SendDuiMessage,
} from '@nativewrappers/client';

let duis: { [key: string]: Dui } = {};
const resourceName = GetCurrentResourceName();

interface LibDui {
  url: string;
  width: number;
  height: number;
  debug?: boolean;
}

export class Dui {
  id: string = "";
  debug: boolean = false;
  url: string = "";
  duiObject: number = 0;
  duiHandle: string = "";
  runtimeTxd: number = 0;
  txdObject: number = 0;
  dictName: string = "";
  txtName: string = "";

  constructor(data: LibDui) {
    const time = GetGameTimer();
    let id = `${resourceName}_${time}_${Math.floor(Math.random() * 1000)}`;
    while (duis[id]) {
      id = `${resourceName}_${time}_${Math.floor(Math.random() * 1000)}`;
    }
    this.id = id;
    this.debug = data.debug || false;
    this.url = data.url;
    this.dictName = `ox_lib_dui_dict_${id}`;
    this.txtName = `ox_lib_dui_txt_${id}`;
    this.duiObject = CreateDui(data.url, data.width, data.height);
    this.duiHandle = GetDuiHandle(this.duiObject);
    this.runtimeTxd = CreateRuntimeTxd(this.dictName);
    this.txdObject = CreateRuntimeTextureFromDuiHandle(this.runtimeTxd, this.txtName, this.duiHandle);

    if (this.debug) console.log(`Dui ${this.id} created`);

    duis[id] = this;
  }

  remove = () => {
    SetDuiUrl(this.duiObject, 'about:blank');
    DestroyDui(this.duiObject);
    delete duis[this.id];

    if (this.debug) console.log(`Dui ${this.id} removed`);
  };

  setUrl = (url: string) => {
    this.url = url;
    SetDuiUrl(this.duiObject, url);

    if (this.debug) console.log(`Dui ${this.id} url set to ${url}`);
  };

  sendMessage = (data: object) => {
    SendDuiMessage(this.duiObject, JSON.stringify(data));

    if (this.debug) console.log(`Dui ${this.id} message sent`);
  }
}

on('onResourceStop', (stoppedResourceName: string) => {
  if (stoppedResourceName !== resourceName) return;

  for (const dui in duis) {
    duis[dui].remove();
  }
});

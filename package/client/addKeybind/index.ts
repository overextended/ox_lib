interface CKeybind extends KeybindProps {
  currentKey: string;
  disabled: boolean;
  isPressed: boolean;
  hash: number;
  getCurrentKey(): string;
  isControlPressed(): boolean;
}

interface KeybindProps {
  name: string;
  description: string;
  defaultMapper?: string;
  defaultKey?: string;
  disabled?: boolean;
  disable?(this: CKeybind, toggle: boolean): void;
  onPressed?(this: CKeybind): void;
  onReleased?(this: CKeybind): void;
  [key: string]: any;
}

const keybinds: Record<string, CKeybind> = {};

class Keybind implements CKeybind {
  name: string;
  description: string;
  defaultMapper?: string;
  defaultKey?: string;
  onPressed?: (this: CKeybind) => void;
  onReleased?: (this: CKeybind) => void;
  secondaryKey?: string;
  secondaryMapper?: string;
  [key: string]: any;

  disabled: boolean = false;
  isPressed: boolean = false;
  hash: number;

  constructor(data: KeybindProps) {
    this.name = data.name;
    this.description = data.description;
    this.defaultMapper = data.defaultMapper ?? "keyboard";
    this.defaultKey = data.defaultKey ?? "";
    this.secondaryKey = data.secondaryKey;
    this.secondaryMapper = data.secondaryMapper;

    if (typeof data.disabled === "boolean") this.disabled = data.disabled;
    this.onPressed = data.onPressed;
    this.onReleased = data.onReleased;

    this.hash = GetHashKey("+" + this.name) | 0x80000000;
  }

  get currentKey(): string {
    return this.getCurrentKey();
  }

  getCurrentKey(): string {
    const label = GetControlInstructionalButton(0, this.hash, true);
    return label.substring(2);
  }

  isControlPressed(): boolean {
    return this.isPressed;
  }

  disable(toggle: boolean): void {
    this.disabled = toggle;
  }
}


export function addKeybind(data: KeybindProps): CKeybind {
  const kb = new Keybind(data);

  keybinds[kb.name] = kb;

  RegisterCommand("+" + kb.name, () => {
    if (kb.disabled || IsPauseMenuActive()) return;
    kb.isPressed = true;
    kb.onPressed?.call(kb);
  }, false);

  RegisterCommand("-" + kb.name, () => {
    if (kb.disabled || IsPauseMenuActive()) return;
    kb.isPressed = false;
    kb.onReleased?.call(kb);
  }, false);

  RegisterKeyMapping(
    "+" + kb.name,
    kb.description,
    kb.defaultMapper ?? "keyboard",
    kb.defaultKey ?? ""
  );

  if (kb.secondaryKey) {
    RegisterKeyMapping(
      "~!+" + kb.name,
      kb.description,
      kb.secondaryMapper ?? kb.defaultMapper ?? "keyboard",
      kb.secondaryKey
    );
  }

  setTimeout(() => {
    emit("chat:removeSuggestion", `/+${kb.name}`);
    emit("chat:removeSuggestion", `/-${kb.name}`);
  }, 500);

  return kb;
}

export function getKeybind(name: string): CKeybind | undefined {
  return keybinds[name];
}

export function getAllKeybinds(): Readonly<Record<string, CKeybind>> {
  return keybinds;
}

interface CKeybind extends KeybindProps {
  currentKey: string;
  disabled: boolean;
  isPressed: boolean;
  hash: number;
  /** Returns the instructional label for the current mapped key. */
  getCurrentKey(): string;
  /** Returns whether the keybind is currently held. */
  isControlPressed(): boolean;
}

interface KeybindProps {
  name: string;
  description: string;
  defaultMapper?: string;
  defaultKey?: string;
  allowInPauseMenu?: boolean;
  disabled?: boolean;
  /** Enables or disables the keybind and resets its pressed state. */
  disable?(this: CKeybind, toggle: boolean): void;
  /** Runs when the enabled keybind is pressed. */
  onPressed?(this: CKeybind): void;
  /** Runs when the enabled keybind is released. */
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
  allowInPauseMenu?: boolean;
  [key: string]: any;

  disabled: boolean = false;
  isPressed: boolean = false;
  hash: number;

  /** Creates a keybind instance from its mapping and handler settings. */
  constructor(data: KeybindProps) {
    this.name = data.name;
    this.description = data.description;
    this.defaultMapper = data.defaultMapper ?? 'keyboard';
    this.defaultKey = data.defaultKey ?? '';
    this.secondaryKey = data.secondaryKey;
    this.secondaryMapper = data.secondaryMapper;
    this.allowInPauseMenu = data.allowInPauseMenu;

    if (typeof data.disabled === 'boolean') this.disabled = data.disabled;
    this.onPressed = data.onPressed;
    this.onReleased = data.onReleased;

    this.hash = GetHashKey('+' + this.name) | 0x80000000;
  }

  /** Returns the instructional label for the current mapped key. */
  get currentKey(): string {
    return this.getCurrentKey();
  }

  /** Returns the mapped key label without its instructional prefix. */
  getCurrentKey(): string {
    const label = GetControlInstructionalButton(0, this.hash, true);
    return label.substring(2);
  }

  /** Returns the pressed state tracked by the keybind commands. */
  isControlPressed(): boolean {
    return this.isPressed;
  }

  /** Sets whether the keybind is disabled and clears its pressed state. */
  disable(toggle: boolean): void {
    this.disabled = toggle;
    this.isPressed = false;
  }
}

/** Registers press and release commands with primary and optional secondary key mappings. */
export function addKeybind(data: KeybindProps): CKeybind {
  const kb = new Keybind(data);

  keybinds[kb.name] = kb;

  RegisterCommand(
    '+' + kb.name,
    () => {
      if (kb.disabled || (!kb.allowInPauseMenu && IsPauseMenuActive())) return;
      kb.isPressed = true;
      kb.onPressed?.call(kb);
    },
    false,
  );

  RegisterCommand(
    '-' + kb.name,
    () => {
      if (kb.disabled || (!kb.allowInPauseMenu && IsPauseMenuActive())) return;
      kb.isPressed = false;
      kb.onReleased?.call(kb);
    },
    false,
  );

  RegisterKeyMapping('+' + kb.name, kb.description, kb.defaultMapper ?? 'keyboard', kb.defaultKey ?? '');

  if (kb.secondaryKey) {
    RegisterKeyMapping(
      '~!+' + kb.name,
      kb.description,
      kb.secondaryMapper ?? kb.defaultMapper ?? 'keyboard',
      kb.secondaryKey,
    );
  }

  setTimeout(() => {
    emit('chat:removeSuggestion', `/+${kb.name}`);
    emit('chat:removeSuggestion', `/-${kb.name}`);
  }, 500);

  return kb;
}

/** Returns the keybind registered under the given name, if present. */
export function getKeybind(name: string): CKeybind | undefined {
  return keybinds[name];
}

/** Returns the registry of keybinds created by this resource. */
export function getAllKeybinds(): Readonly<Record<string, CKeybind>> {
  return keybinds;
}

import { cache } from '../cache';

const hooks: Set<HookPipeline> = new Set();

on('onResourceStop', (resource: string) => {
  for (let hook of hooks) hook.remove(resource);
});

export interface Hook extends HookOptions {
  resource: string;
  hookId: string;
  cb: (payload: any) => boolean;
}

interface HookOptions {
  [key: string]: any;
}

export class HookPipeline<T = any> {
  private hooks: Hook[];

  readonly event;
  readonly filter;

  /**
   * Creates a hook pipeline for a specific event.
   * The pipeline manages a collection of registered hooks and controls execution
   * flow through filtering, rejection, and dispatching.
   *
   * It also exposes external resource hooks:
   * - `registerHook:<event>` adds a hook to the pipeline
   * - `removeHook:<event>` removes a hook from the pipeline
   */
  constructor(event: string, filter?: (hook: Hook, payload: T) => boolean) {
    this.hooks = [];
    this.event = event;
    this.filter = filter;

    hooks.add(this);

    exports(`registerHook:${event}`, (ref: Hook['cb'], options?: HookOptions) => this.registerHook(ref, options));

    exports(`removeHook:${event}`, (hookId: string) => {
      const resource = GetInvokingResource() || cache.resource;

      this.remove(resource, hookId);
    });
  }

  /**
   * Registers a hook into the pipeline for the current event.
   * @param options Optional metadata attached to the hook.
   */
  public registerHook(cb: Hook['cb'] | null, options?: HookOptions) {
    const idx = this.hooks.length;
    const resource = GetInvokingResource() || cache.resource;
    const hook = {} as Hook;

    if (options) Object.assign(hook, options);
    if (cb) hook.cb = cb;

    hook.resource = resource || cache.resource;
    hook.hookId = `${resource}:${this.event}:${idx}`;

    this.hooks.push(hook);

    return hook.hookId;
  }

  /**
   * Removes hooks from the pipeline.
   * - If `hookId` is provided, only the matching hook is removed.
   * - If omitted, all hooks belonging to the invoking resource are removed.
   */
  public remove(resource: string, hookId?: string) {
    for (let i = this.hooks.length - 1; i >= 0; i--) {
      const hook = this.hooks[i]!;

      if (hook.resource === resource && (!hookId || hook.hookId === hookId)) {
        this.hooks.splice(i, 1);
      }
    }
  }

  /**
   * Executes the hook pipeline for the payload.
   *
   * Each registered hook is evaluated in order of registration, checking the payload against a provided filter\
   * using the hook options and executing the hook callback.
   *
   * A hook may block execution by returning `false` from the pipeline filter or its own callback.
   *
   * If any hook rejects the execution, dispatch is cancelled and `result.ok` is set to `false`.
   *
   * The returned object acts as a finalisation handle and emits results to registered handlers once closed.
   */
  public dispatch(payload: T) {
    const events: string[] = [];

    const result = {
      ok: true,
      size: 0,
      [Symbol.dispose]: () => {
        // @ts-expect-error
        const packed = msgpack_pack([result.ok, payload]);

        for (let event of events) TriggerEventInternal(event, packed, packed.length);
      },
    };

    for (let hook of this.hooks) {
      const runHook = this.filter?.(hook, payload) !== false;
      const rejected = runHook && hook.cb?.(payload) === false;

      if (runHook) events.push(hook.hookId);

      if (rejected) {
        result.ok = false;
        break;
      }
    }

    result.size = events.length;

    return result;
  }
}

type PostHookEvent = (ok: boolean, payload: any) => void;

class EventHook {
  private handler?: PostHookEvent;
  /** Creates a new EventHook instance bound to a specific exported hook. */
  constructor(
    readonly hookId: string,
    readonly resource: string,
    readonly event: string,
  ) {}

  /**
   * ---Attaches a post-execution event handler for this hook.
   * The handler is triggered after the hooked event completes and receives:
   * - `ok` whether the original event execution succeeded
   * - `payload` the returned or processed event data
   *
   * If a handler is already registered, it will be replaced.
   */
  public on(handler: PostHookEvent) {
    this.off();
    this.handler = handler;

    on(this.hookId, this.handler);
  }

  /** Detaches the currently registered post-hook event handler, if one exists. */
  public off() {
    if (!this.handler) return;

    removeEventListener(this.hookId, this.handler);
  }

  /**
   * Fully removes this hook from both the local event system and the external
   * hook registry provided by the originating resource.
   *
   * This invalidates the hook instance; it should not be used afterward.
   */
  public remove() {
    this.off();
    exports[this.resource]![`removeHook:${this.event}`]!(this.hookId);
  }
}

export function registerHook(eventName: string, handler?: Hook['cb'] | null, options?: HookOptions) {
  const [resource, event] = eventName.split(':', 2);

  if (!resource || !event) throw new Error(`Invalid event format: ${eventName} (expected "resourceName:eventName")`);

  if (handler && !options && typeof handler !== 'function') {
    options = handler;
    handler = null;
  }

  const hookId = exports[resource][`registerHook:${event}`](handler, options);

  return new EventHook(hookId, resource, event);
}

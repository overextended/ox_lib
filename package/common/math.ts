import { waitFor } from './utils';
import { Vector } from './vector';

/**
 * Clamps a number between a minimum and maximum value.
 *
 * @param value The number to clamp.
 * @param min The minimum value.
 * @param max The maximum value.
 * @returns The clamped number.
 */
export function clamp(value: number, min: number, max: number): number {
    return Math.max(min, Math.min(max, value));
}

/**
 * Formats a number into digits grouped by thousands.
 *
 * @param value The number to format (supports negative and decimals).
 * @param separator Separator for digit groups (default is ',').
 */
export function delimitNumber(value: number, separator = ','): string {
    const sign = value < 0 ? '-' : '';
    const abs = Math.abs(value);
    const [int, decimal] = abs.toString().split('.');
    const groupedInt = int?.replace(/\B(?=(\d{3})+(?!\d))/g, () => separator)

    return sign + (decimal ? `${groupedInt}.${decimal}` : groupedInt);
}

/**
 * Calculates an intermediate value between two values based on the interpolation factor.
 * @param start The initial value.
 * @param finish The final value.
 * @param factor The interpolation factor, typically between 0 and 1.
 */
export function lerp(start: number, finish: number, factor: number): number {
    return start + (finish - start) * factor;
}

/**
 * Linearly interpolates from the start value to the finish over the specified duration.
 * @param start The initial value.
 * @param finish The final value.
 * @param duration The duration of the interpolation in milliseconds.
 * @param onUpdate A function to be called on each update.
 * @param interval The frequency at which the value is updated in milliseconds.
 * @returns A promise that resolves with the final value once reached.
 */
export function lerpTo<
    T extends number | Vector,
    Widen = T extends number ? number : T, // annoying ass number literal
>(
    start: T,
    finish: T,
    duration: number,
    onUpdate?: (value: Widen, start: Widen, finish: Widen) => void,
    interval = 0,
): Promise<Widen> {
    let value = (typeof start === 'number' ? start : start.clone()) as Widen;
    const startTime = performance.now();

    return waitFor(() => {
        const elapsed = performance.now() - startTime;
        const factor = Math.min(elapsed / duration, 1);

        value = (
            typeof start === 'number'
                ? start + ((finish as number) - start) * factor
                : (value as Vector).copy(start).lerp(finish, factor)
        ) as Widen;

        onUpdate?.(value, start as unknown as Widen, finish as unknown as Widen);

        if (factor === 1) return value;
    }, { interval });
}
import { cache } from "../cache";

type LogLevel = 'error' | 'warn' | 'info' | 'verbose' | 'debug'

interface LogMetadata {
    players?: number[];
    [key: string]: any;
}

interface LogEntry {
    level: LogLevel;
    message: string;
    metadata?: LogMetadata;
}

const logs: LogEntry[] = [];

function logger(level: LogLevel, message: string, metadata?: LogMetadata) {
    if (logs.length === 0) setTimeout(() => {
        exports.ox_lib.internal_logMessage(cache.resource, logs)
        logs.length = 0;
    }, 50)

    logs.push({ level, message, metadata })
}

export default logger;

export const error = (message: string, metadata?: LogMetadata) => logger('error', message, metadata);
export const warn = (message: string, metadata?: LogMetadata) => logger('warn', message, metadata);
export const info = (message: string, metadata?: LogMetadata) => logger('info', message, metadata);
export const verbose = (message: string, metadata?: LogMetadata) => logger('verbose', message, metadata);
export const debug = (message: string, metadata?: LogMetadata) => logger('debug', message, metadata);
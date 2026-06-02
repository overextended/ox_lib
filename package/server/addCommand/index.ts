import { addAce } from '../acl';

type OxCommandArguments = Record<string | number, string | number | boolean>;

interface OxCommandParams {
  name: string;
  help?: string;
  type?: 'number' | 'playerId' | 'string' | 'longString';
  optional?: boolean;
}

interface OxCommandProperties {
  name?: string;
  help?: string;
  params?: OxCommandParams[];
  restricted?: boolean | string | string[];
}

const registeredCommmands: OxCommandProperties[] = [];
let shouldSendCommands = false;

setTimeout(() => {
  shouldSendCommands = true;
  emitNet('chat:addSuggestions', -1, registeredCommmands);
}, 1000);

on('playerJoining', () => {
  emitNet('chat:addSuggestions', source, registeredCommmands);
});

function parseArguments(
  source: number,
  args: OxCommandArguments,
  raw: string,
  params?: OxCommandParams[],
): OxCommandArguments | undefined {
  if (!params) return args;

  const result = params.every((param, index) => {
    const arg = args[index];
    let value;

    switch (param.type) {
      case 'number':
        value = +arg;
        break;

      case 'string':
        value = !Number(arg) ? arg : false;
        break;

      case 'playerId':
        value = arg === 'me' ? source : +arg;
        if (!value || !DoesPlayerExist(value.toString())) value = false;

        break;

      case 'longString':
        value = raw.substring(raw.indexOf(arg as string));
        break;

      default:
        value = arg;
        break;
    }

    if (value === undefined && (!param.optional || (param.optional && arg))) {
      return Citizen.trace(
        `^1command '${raw.split(' ')[0] || raw}' received an invalid ${param.type} for argument ${index + 1} (${
          param.name
        }), received '${arg}'^0`,
      );
    }

    args[param.name] = value;
    delete args[index];

    return true;
  });

  return result ? args : undefined;
}

function buildSuggestion(commandName: string, { params, help }: OxCommandProperties) {
  const hints = params
    ? params.map((param) => {
        return {
          name: param.name,
          help: param.type
            ? param.help
              ? `${param.help} (type: ${param.type})`
              : `(type: ${param.type})`
            : param.help,
        };
      })
    : undefined;

  return {
    name: `/${commandName}`,
    help: help,
    params: hints,
  };
}

export function addCommand<T extends OxCommandArguments>(
  commandName: string | string[],
  cb: (source: number, args: T, raw: string) => Promise<any>,
  properties?: OxCommandProperties,
) {
  const restricted = properties?.restricted;
  const params = properties?.params;
  const commands = typeof commandName !== 'object' ? [commandName] : commandName;

  if (params) {
    params.forEach((param) => {
      if ('argType' in param) {
        param.type = param.argType as OxCommandParams['type'];
        delete param.argType;
      }
    });
  }

  const commandHandler = (source: number, args: OxCommandArguments, raw: string) => {
    const parsed = parseArguments(source, args, raw, params) as T | undefined;

    if (!parsed) return;

    cb(source, parsed, raw).catch((e) =>
      Citizen.trace(`^1command '${raw.split(' ')[0] || raw}' failed to execute!^0\n${e.message}`),
    );
  };

  commands.forEach((commandName) => {
    RegisterCommand(commandName, commandHandler, restricted ? true : false);

    if (restricted) {
      const ace = `command.${commandName}`;

      if (typeof restricted === 'string' && !IsPrincipalAceAllowed(restricted as string, ace)) {
        addAce(restricted as string, ace, true);
      } else if (Array.isArray(restricted)) {
        restricted.forEach((principal) => {
          if (!IsPrincipalAceAllowed(principal, ace)) addAce(principal as string, ace, true);
        });
      }
    }

    if (properties) {
      const suggestion = buildSuggestion(commandName, properties);
      registeredCommmands.push(suggestion);

      if (shouldSendCommands) emitNet('chat:addSuggestions', -1, suggestion);
    }
  });
}

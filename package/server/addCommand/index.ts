import { addAce } from '../acl';

type OxCommandArguments = Record<string | number, string | number | boolean>;

interface OxCommandParams {
  name: string;
  help?: string;
  paramType?: 'number' | 'playerId' | 'string' | 'longString';
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
  params?: OxCommandParams[]
): OxCommandArguments | undefined {
  if (!params) return args;

  const result = params.every((param, index) => {
    const arg = args[index];
    let value;

    switch (param.paramType) {
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
        `^1command '${raw.split(' ')[0] || raw}' received an invalid ${param.paramType} for argument ${index + 1} (${
          param.name
        }), received '${arg}'^0`
      );
    }

    args[param.name] = value;
    delete args[index];

    return true;
  });

  return result ? args : undefined;
}

export function addCommand<T extends OxCommandArguments>(
  commandName: string | string[],
  cb: (source: number, args: T, raw: string) => Promise<any>,
  properties?: OxCommandProperties
) {
  const restricted = properties?.restricted;
  const params = properties?.params;

  if (params) {
    params.forEach((param) => {
      if (param.paramType)
        param.help = param.help ? `${param.help} (type: ${param.paramType})` : `(type: ${param.paramType})`;
    });
  }

  const commands = typeof commandName !== 'object' ? [commandName] : commandName;
  const numCommands = commands.length;

  const commandHandler = (source: number, args: OxCommandArguments, raw: string) => {
    const parsed = parseArguments(source, args, raw, params) as T | undefined;

    if (!parsed) return;

    cb(source, parsed, raw).catch((e) =>
      Citizen.trace(`^1command '${raw.split(' ')[0] || raw}' failed to execute!^0\n${e.message}`)
    );
  };

  commands.forEach((commandName, index) => {
    RegisterCommand(commandName, commandHandler, restricted ? true : false);

    if (restricted) {
      const ace = `command.${commandName}`;
      const restrictedType = typeof restricted;

      if (restrictedType === 'string' && !IsPrincipalAceAllowed(restricted as string, ace)) {
        addAce(restricted as string, ace, true);
      } else if (restrictedType === 'object') {
        const _restricted = restricted as string[];
        _restricted.forEach((principal) => {
          if (!IsPrincipalAceAllowed(principal, ace)) addAce(principal as string, ace, true);
        });
      }
    }

    if (properties) {
      properties.name = `/${commandName}`;
      delete properties.restricted;
      registeredCommmands.push(properties);

      if (index !== numCommands && numCommands !== 1) properties = { ...properties };

      if (shouldSendCommands) emitNet('chat:addSuggestions', -1, properties);
    }
  });
}

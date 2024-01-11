import { addAce } from "../acl";

type OxCommandArguments = Record<(string|number), string | number | boolean>;

interface OxCommandParams {
    name: string;
    help?: string;
    paramType?: 'number' | 'playerId' | 'string';
    optional?: boolean;
}

interface OxCommandProperties {
    name?: string;
    help?: string;
    params?: OxCommandParams[];
    restricted?: boolean | string | string[];
}

let registeredCommmands: OxCommandProperties[] = [];
let shouldSendCommands = false;

setTimeout(() => {
    shouldSendCommands = true;
    emitNet('chat:addSuggestions', -1, registeredCommmands);
}, 1000)

on('playerJoining', (source: number) => {
    emitNet('chat:addSuggestions', source, registeredCommmands);
})

function parseArguments(source: number, args: OxCommandArguments, raw: string, params?: OxCommandParams[]): OxCommandArguments | undefined {
    if (!params) {
        return args;
    }

    let paramMissing = false

    params.every((param, index) => {
        let arg = args[index]
        let value: any

        switch (param.paramType) {
            case 'number':
                value = Number(arg);
                break;

            case 'string':
                value = !Number(arg) ? arg : false;
                break;

            case 'playerId':
                value = arg === 'me' ? source : Number(arg);
                if (!value || !GetPlayerGuid(value)) {
                    value = false;
                }
                break;

            default:
                value = arg;
                break;
        }

        if (!value && (!param.optional || param.optional && arg)) {
            paramMissing = true
            return Citizen.trace(`^1command '${raw.split(' ') || raw}' received an invalid ${param.paramType} for argument ${index} (${param.name}), received '${arg}'^0`);
        }

        arg = value;

        args[param.name] = arg;
        delete(args[index]);
    })

    return !paramMissing ? args : undefined;
};

export function addCommand(commandName: string | string[], cb: (source: number, args: object, raw: string) => any, properties?: OxCommandProperties) {
    let restricted = properties?.restricted;
    let params = properties?.params;

    if (params) {
        params.forEach((param) => {
            if (param.paramType) {
                param.help = (param.help) ? `${param.help} (type: ${param.paramType})` : `(type: ${param.paramType})`;
            }
        })
    }

    let commands = typeof commandName !== 'object' ? [ commandName ] : commandName;
    let numCommands = commands.length;

    const commandHandler = (source: number, args: OxCommandArguments, raw: string) => {
        let parsed: OxCommandArguments | undefined = parseArguments(source, args, raw, params);
        if (!parsed) {
            return;
        }

        cb(source, parsed, raw)
    }

    commands.forEach((commandName, index) => {
        RegisterCommand(commandName, commandHandler, restricted ? true : false)

        if (restricted) {
            let ace = `command.${commandName}`;
            let restrictedType = typeof restricted;

            if (restrictedType === 'string' && (!IsPrincipalAceAllowed(restricted as string, ace))) {
                addAce(restricted as string, ace, true)
            }
            else if (restrictedType === 'object') {
                let _restricted = restricted as string[];
                _restricted.forEach((principal) => {
                    if (!IsPrincipalAceAllowed(principal, ace)) {
                        addAce(principal as string, ace, true)
                    }
                })
            }
        }

        if (properties) {
            properties.name = `/${commandName}`;
            delete properties.restricted;
            registeredCommmands.push(properties);

            if (index !== numCommands && numCommands !== 1) {
                properties = Object.assign({}, properties);
            }

            if (shouldSendCommands) { emitNet('chat:addSuggestions', -1, properties); }
        }
    })
};
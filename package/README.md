# ox_lib JS/TS wrapper

Not all ox_lib functions found in Lua are supported, the ones that are will have a JS/TS example
on the documentation.

You still need to use and have the ox_lib resource included into the resource you are using the npm package in.

## Installation

```yaml
# With pnpm
pnpm add @communityox/ox_lib

# With Yarn
yarn add @communityox/ox_lib

# With npm
npm install @communityox/ox_lib
```

## Usage
You can either import the lib from client or server files or deconstruct the object and import only certain functions
you may require.

```ts
import lib from '@communityox/ox_lib/client'
```

```ts
import lib from '@communityox/ox_lib/server'
```

```ts
import { checkDependency } from '@communityox/ox_lib/shared';
```

## Documentation
[View documentation](https://coxdocs.dev/ox_lib)
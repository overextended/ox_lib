# ox_lib JS/TS wrapper

Not all ox_lib functions found in Lua are supported, the ones that are will have a JS/TS example
on the documentation.

Currently, all the available functions for JS/TS can be found under the `resource` folder in  
ox_lib.

## Installation

```yaml
# With pnpm
pnpm add @overextended/ox_lib

# With Yarn
yarn add @overextended/ox_lib

# With npm
npm install @overextended/ox_lib
```

## Usage
You can either import the lib from client or server files or deconstruct the object and import only certain functions
you may require.

```ts
import lib from '@overextended/ox_lib/client'
```

```ts
import lib from '@overextended/ox_lib/server'
```

```ts
import { checkDependency } from '@overextended/ox_lib/shared';
```

## Documentation
[View documentation](https://overextended.github.io/docs/ox_lib)
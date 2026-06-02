# REDasm Workspace
CI and developer setup for building the full REDasm project from source.
 
For bug reports, feature requests and general discussion [see here](https://github.com/redasm-dev/redasm).

## Requirements
- CMake 3.25+
- Git
- Qt 6
- A C compiler (C17 Standard)

## Getting Started
Clone this repo and run `Setup.cmake` to fetch all components:

```sh
git clone https://github.com/redasm-dev/workspace
cd workspace
cmake -P Setup.cmake
cmake -B build
cmake --build build
```

## Pinning Versions (CI / Release)
Each component version can be overridden via `-D` flags or environment variables:

```sh
cmake \
  -DCORE_VERSION=v4.0.1 \
  -DREDASM_VERSION=v4.0.1 \
  -DLOADERS_VERSION=v4.0.1 \
  -DPROCESSORS_VERSION=v4.0.1 \
  -DCOMMANDS_VERSION=v4.0.1 \
  -DANALYZERS_VERSION=v4.0.1 \
  -DKB_VERSION=v4.0.1 \
  -P Setup.cmake
```

Defaults to `master` for all components if not specified.

## Repository Layout
|                          Repo                          |      Description      |
|-------------------------------------------------------:|:----------------------|
| [core](https://github.com/redasm-dev/core)             | Core library (Engine) |
| [gui](https://github.com/redasm-dev/redasm)            | GUI (Qt6)             |
| [loaders](https://github.com/redasm-dev/loaders)       | Loader plugins        |
| [processors](https://github.com/redasm-dev/processors) | Processor plugins     |
| [commands](https://github.com/redasm-dev/commands)     | Command plugins       |
| [analyzers](https://github.com/redasm-dev/analyzers)   | Analyzer plugins      |
| [kb](https://github.com/redasm-dev/kb)                 | Knowledge Base        |

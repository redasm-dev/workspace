# REDasm Workspace
CI and developer setup for building the full REDasm project from source.
 
For bug reports, feature requests and general discussion [see here](https://github.com/redasm-dev/redasm).

## Requirements
- CMake 3.25
- C17 (core) & C++17 (GUI)
- Qt 6.8 LTS (GUI)
- Git

### Windows
Tested on **Visual Studio 2022**

Qt can be installed via [aqtinstall](https://github.com/miurahr/aqtinstall):

```sh
pip install aqtinstall
aqt install-qt windows desktop 6.8.3 win64_msvc2022_64 -O C:\Qt
```

### Linux
All requirements are met by the default **Debian 13** repositories, no additional steps needed.

```sh
sudo apt install build-essential cmake git qt6-base-dev qt6-tools-dev
```


## Getting Started
Clone this repo and run `Setup.cmake` to fetch all components:

```sh
git clone https://github.com/redasm-dev/workspace
cd workspace
cmake -P Setup.cmake
```

Configure the build, specifying the Qt installation path:
 
```sh
# Windows
cmake -B build -DCMAKE_PREFIX_PATH=C:\Qt\6.8.3\msvc2022_64
 
# Linux (only needed if Qt is not installed system-wide)
cmake -B build -DCMAKE_PREFIX_PATH=/path/to/qt
```

Then build:
 
```sh
# Debug
cmake --build build --config Debug
 
# Release
cmake --build build --config Release
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

## Building an AppImage (Linux)

Install `linuxdeploy` and the Qt plugin:

```sh
wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
wget https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage
chmod +x linuxdeploy-x86_64.AppImage linuxdeploy-plugin-qt-x86_64.AppImage
```

Configure and build in Release, then install into a staging directory:

```sh
cmake -B build
cmake --build build --config Release
cmake --install build --prefix AppDir/usr
```

Generate the AppImage:

```sh
QMAKE=$(which qmake6) ./linuxdeploy-x86_64.AppImage \
    --appdir AppDir \
    --plugin qt \
    --output appimage
```

The resulting `REDasm-x86_64.AppImage` will be in the current directory.

## Repository Layout
|                          Repo                          |      Description      |
|-------------------------------------------------------:|:----------------------|
| [core](https://github.com/redasm-dev/core)             | Core library (Engine) |
| [redasm](https://github.com/redasm-dev/redasm)         | GUI Frontend (Qt6)    |
| [loaders](https://github.com/redasm-dev/loaders)       | Loader plugins        |
| [processors](https://github.com/redasm-dev/processors) | Processor plugins     |
| [commands](https://github.com/redasm-dev/commands)     | Command plugins       |
| [analyzers](https://github.com/redasm-dev/analyzers)   | Analyzer plugins      |
| [kb](https://github.com/redasm-dev/kb)                 | Knowledge Base        |

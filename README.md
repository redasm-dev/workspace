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
All requirements are met by the default **Ubuntu 24.04 LTS** repositories, no additional steps needed.

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
# Windows (adjust the Qt path to match your installation)
cmake -B build -DCMAKE_PREFIX_PATH=C:\Qt\6.8.3\msvc2022_64
 
# Linux (only needed if Qt is not installed system-wide)
cmake -B build -DCMAKE_PREFIX_PATH=/path/to/qt
```

Then build:
 
```sh
# Linux: build type set at configure time, not build time
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel

# Windows: build type set at build time via --config
cmake --build build --config Release --parallel
```

If needed, change the build type to `Debug`

## Running Tests
 
Fetch the test suite and sample binaries alongside the other components:

```sh
cmake -DREDASM_FETCH_TESTS=ON -P Setup.cmake
```
 
Configure with the samples path and build:
 
```sh
# Linux
cmake -B build -DREDASM_SAMPLES=/path/to/workspace/samples
 
# Windows
cmake -B build -DCMAKE_PREFIX_PATH=C:\Qt\6.8.3\msvc2022_64 -DREDASM_SAMPLES=C:\path\to\workspace\samples
```
 
Run the tests:
 
```sh
# Linux
ctest --test-dir build --output-on-failure
 
# Windows
ctest --test-dir build -C Release --output-on-failure
```

## Pinning Versions (CI / Release)
Pin every component to the same version with a single flag:
 
```sh
cmake -DREDASM_VERSION_DEFAULT=v4.0.1 -P Setup.cmake
```

Defaults to `master` for all components if not specified.

Individual components can be overridden on top of the default (useful for local testing against a branch):
```sh
cmake \
  -DREDASM_VERSION_DEFAULT=v4.0.1 \
  -DLOADERS_VERSION=my-feature-branch \
  -P Setup.cmake
```
Available overrides: `CORE_VERSION`, `GUI_VERSION`, `LOADERS_VERSION`, `PROCESSORS_VERSION`,
`COMMANDS_VERSION`, `ANALYZERS_VERSION`.  
Each falls back to `REDASM_VERSION_DEFAULT` if unset.

### Knowledge Base has it's own versioning
 
The `kb` can be compatible within a series of REDasm releases.  
Because of this, `KB_VERSION` does **not** fall back to `REDASM_VERSION_DEFAULT`: it always defaults straight to `master`,
but it can be overrided to a specific Git ref, if needed:

```sh
# core/redasm/loaders/... pinned to v4.0.1, kb still tracks master
cmake -DREDASM_VERSION_DEFAULT=v4.0.1 -P Setup.cmake
 
# pin kb explicitly 
cmake -DREDASM_VERSION_DEFAULT=v4.0.1 -DKB_VERSION=kb-v1.0 -P Setup.cmake
```

## Building an AppImage (Linux)

Install `linuxdeploy` and the Qt plugin:

```sh
wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
wget https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage
chmod +x linuxdeploy-x86_64.AppImage linuxdeploy-plugin-qt-x86_64.AppImage
```

Configure and build in Release, then install into a staging directory:

```sh
cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
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

## Verifying Release Signatures

All release artifacts are GPG signed. Import the appropriate public key to verify:

```sh
# Stable releases
gpg --keyserver keys.openpgp.org --recv-keys B0C728D7021EEEE9D9B859043AF46EB2201FFB56
 
# Nightly builds
gpg --keyserver keys.openpgp.org --recv-keys A2391AFACAE2EE52B35541DD65F948A2F6BB294A
```

Verify a downloaded artifact:
 
```sh
gpg --verify REDasm-linux-x86_64.AppImage.asc REDasm-linux-x86_64.AppImage
gpg --verify REDasm-windows-x86_64.zip.asc REDasm-windows-x86_64.zip
```

Key fingerprints:
 
| Key | Fingerprint |
|---|---|
| REDasm Release `release@redasm.dev` | `B0C7 28D7 021E EEE9 D9B8  5904 3AF4 6EB2 201F FB56` |
| REDasm Nightly `nightly@redasm.dev` | `A239 1AFA CAE2 EE52 B355  41DD 65F9 48A2 F6BB 294A` |

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
| [tests](https://github.com/redasm-dev/tests)           | Test suite            |
| [samples](https://github.com/redasm-dev/samples)       | Sample binaries       |

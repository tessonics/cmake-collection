# Cmake Collection

A loose collection of cmake scripts used by different departments

The idea is to have a place where we can loosely collect any cmake script that can be reused by any software we have or create

| CMake Module                        | Description                                        |
| ----------------------------------- | -------------------------------------------------- |
| [AddGitSubmodule](#addgitsubmodule) | Adds a Git submodule directory to cmake            |
| [GetGitVersion](#getgitversion)     | Parses the most recent git tag                     |
| [Version](#version)                 | Generates a version header file for a given target |

## AddGitSubmodule

Adds a Git submodule directory to cmake, assumed the directory is a CMake project containing a `CMakeLists.txt`.
If the directory does not contain a `CMakeLists.txt` `git submodule update --init --recursive` will be executed on that folder

### Example usage:

```cmake
include(cmake/AddGitSubmodule.cmake)
add_git_submodule(submodule_dir)
```

## GetGitVersion

Parses the most recent git tag, expects tags in the form:
`<major>.<minor>.<patch>[-tail]`
any prefix will be ignored

### Options

| Parameter            | Description                                                                  |
| -------------------- | ---------------------------------------------------------------------------- |
| INCLUDE_COMMIT_COUNT | Additionally get the number of commits ahead of the most recent version tag. |

### Output

| Variable            | Description                                                                                                                                                                                                                                                                            |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GIT_VER_MAJOR       | Major number extracted from git tag.                                                                                                                                                                                                                                                   |
| GIT_VER_MINOR       | Minor number extracted from git tag.                                                                                                                                                                                                                                                   |
| GIT_VER_PATCH       | PATCH number extracted from git tag.                                                                                                                                                                                                                                                   |
| GIT_VER_TAIL        | Tail extracted from git tag.                                                                                                                                                                                                                                                           |
| GIT_VER_BUILD       | Quad build number derived from git tail see [GIT_VERSION_BUILD](#GIT_VERSION_BUILD)                                                                                                                                                                                                    |
| GIT_VER_STR         | Human readable version string constructed from the parsed components, compounded with a `-` Format: `<major>-<minor>-<patch>[-<tail>]`.                                                                                                                                                |
| GIT_VER_SEM         | A semantic version compatible version string constructed from the parsed components, compound with a `.`.<br>If `INCLUDE_COMMIT_COUNT` is enabled the version string will also contain the number of additional commits. Format: `v<major>.<minor>.<patch>[-<tail>][+<commit_count>]`. |
| GIT_COMMIT_COUNT    | Contains the additional commits since the last version tag. Only set if called with the OPTION `INCLUDE_COMMIT_COUNT` and the number of additional commits is greater then 0.                                                                                                          |
| GIT_VER_NNNN        | Contains the Major Minor Patch Build as a comma separated string                                                                                                                                                                                                                       |
| BUILD_TIMESTAMP_RFC | Contains the build timestamp in RFC-3339 format, expressed in Coordinated Universal Time (UTC).                                                                                                                                                                                        |
| BUILD_TIMESTAMP_HR  | Contains the build timestamp in a human readable format, expressed in Coordinated Universal Time (UTC).                                                                                                                                                                                |
| GIT_LONG_HASH       | The long hash of the last commit                                                                                                                                                                                                                                                       |
| GIT_SHORT_HASH      | The short hash of the last commit                                                                                                                                                                                                                                                      |
| GIT_AUTHOR_DATE     | Date of the last commit                                                                                                                                                                                                                                                                |

### Example usage:

```cmake
include(cmake/GetGitVersion.cmake)
get_git_version_info()
```

If the latest tag would be `v1.5.2-beta` and since then 10 additional commits where added the output would be the following:
| Variable | Value |
| ------------------- | ----------------------- |
| GIT_VERSION_MAJOR | 1 |
| GIT_VERSION_MINOR | 5 |
| GIT_VERSION_PATCH | 2 |
| GIT_VERSION_TAIL | beta |
| GIT_VERSION_BUILD | 20010 |
| GIT_VER_STR | 1-5-2-beta |
| GIT_VER_SEM | v1.5.2-beta |
| BUILD_TIMESTAMP_RFC | 1970-01-01T00:00:00Z |
| BUILD_TIMESTAMP_HR | 1970-01-01 00:00:00 UTC |

```cmake
include(cmake/GetGitVersion.cmake)
get_git_version_info(INCLUDE_COMMIT_COUNT)
```

If the latest tag would be `v1.5.2-beta` and since then 10 additional commits where added the output would be the following:
| Variable | Value |
| ------------------- | ----------------------- |
| GIT_VERSION_MAJOR | 1 |
| GIT_VERSION_MINOR | 5 |
| GIT_VERSION_PATCH | 2 |
| GIT_VERSION_TAIL | beta |
| GIT_VERSION_BUILD | 20010 |
| GIT_COMMIT_COUNT | 10 |
| GIT_VER_STR | 1-5-2-beta |
| GIT_VER_SEM | v1.5.2-beta+10 |
| BUILD_TIMESTAMP_RFC | 1970-01-01T00:00:00Z |
| BUILD_TIMESTAMP_HR | 1970-01-01 00:00:00 UTC |

### GIT_VERSION_BUILD

Quad build number derived from git tail. Supported tails are in the format `-[<name>.][<number>]`
`<name>` can be alpha, beta, rc if no name is given, release is assumed.
The quad base is depending on the of the `<name>`

- alpha: 10000
- beta: 20000
- rc: 30000
- release 50000
  the `<number>` is if present, multiplied by 100 and added to the base.
  The additional commits is added to the Build number

Examples:

- v1.0.0-alpha -> 10000
- v1.0.0-alpha.1 -> 10100
- v1.0.0-alpha.1 + 7 commits -> 10107
- v1.0.0-rc.5 -> 30500
- v1.0.0 -> 50000
- v1.0.0.5 -> 50500

## Version

Generates a `version.h` header file for a specific target in the `CMAKE_CURRENT_BINARY_DIR` directory.
The `CMAKE_CURRENT_BINARY_DIR` is also added as an include_directory to the specified target.
The file will be named default to `${TARGET}_version.h` if a target is specified otherwise to `version.h`

```cmake
make_version(
    [TARGET name]
    [FORCE_RUN_GET_GITVERSION]
    [DISABLE_INCLUDE_DIRECTORY]
    [OUTPUT_FOLDER path]
    [OUTPUT_FILE path]
)
```

### Arguments

| Parameter                 | Description                                                                                                                                  |
| ------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| TARGET                    | The TARGET for which a version header file should be generated                                                                               |
| FORCE_RUN_GET_GITVERSION  | If set GetGitVersion runs whether it already run or not                                                                                      |
| DISABLE_INCLUDE_DIRECTORY | If set the OUTPUT_FOLDER will not be set as an include directory                                                                             |
| OUTPUT_FOLDER             | Sets the folder to where the generated version header file will be saved defaults to `${CMAKE_CURRENT_BINARY_DIR}`                           |
| OUTPUT_FILE               | Sets the file name for the generated version header file defaults to `${TARGET}_version.h` if a target is specified otherwise to `version.h` |

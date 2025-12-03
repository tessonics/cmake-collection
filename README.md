# Cmake Collection

A loose collection of cmake scripts used by different departments

The idea is to have a place where we can loosely collect any cmake script that can be reused by any software we have or create

| CMake Module                        | Description                             |
| ----------------------------------- | --------------------------------------- |
| [AddGitSubmodule](#addgitsubmodule) | Adds a Git submodule directory to cmake |
| [GetGitVersion](#getgitversion)     | Parses the most recent git tag          |

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
| GIT_VERSION_MAJOR   | Major number extracted from git tag.                                                                                                                                                                                                                                                   |
| GIT_VERSION_MINOR   | Minor number extracted from git tag.                                                                                                                                                                                                                                                   |
| GIT_VERSION_BUILD   | Build number extracted from git tag.                                                                                                                                                                                                                                                   |
| GIT_VERSION_TAIL    | Tail extracted from git tag.                                                                                                                                                                                                                                                           |
| GIT_VER_STR         | Human readable version string constructed from the parsed components, compounded with a `-` Format: `<major>-<minor>-<patch>[-<tail>]`.                                                                                                                                                |
| GIT_VER_SEM         | A semantic version compatible version string constructed from the parsed components, compound with a `.`.<br>If `INCLUDE_COMMIT_COUNT` is enabled the version string will also contain the number of additional commits. Format: `v<major>.<minor>.<patch>[-<tail>][+<commit_count>]`. |
| GIT_COMMIT_COUNT    | Contains the additional commits since the last version tag. Only set if called with the OPTION `INCLUDE_COMMIT_COUNT` and the number of additional commits is greater then 0.                                                                                                          |
| BUILD_TIMESTAMP_RFC | Contains the build timestamp in RFC-3339 format, expressed in Coordinated Universal Time (UTC).                                                                                                                                                                                        |
| BUILD_TIMESTAMP_HR  | Contains the build timestamp in a human readable format, expressed in Coordinated Universal Time (UTC).                                                                                                                                                                                |

### Example usage:

```cmake
include(cmake/GetGitVersion.cmake)
get_git_version_info()
```

If the latest tag would be `v1.5.2-beta` the output would be the following:
| Variable | Value |
| ----------------- | ----------- |
| GIT_VERSION_MAJOR | 1 |
| GIT_VERSION_MINOR | 5 |
| GIT_VERSION_BUILD | 2 |
| GIT_VERSION_TAIL | beta |
| GIT_VER_STR | 1-5-2-beta |
| GIT_VER_SEM | v1.5.2-beta |
| BUILD_TIMESTAMP_RFC | 1970-01-01T00:00:00Z |
| BUILD_TIMESTAMP_HR | 1970-01-01 00:00:00 UTC |

```cmake
include(cmake/GetGitVersion.cmake)
get_git_version_info(INCLUDE_COMMIT_COUNT)
```

If the latest tag would be `v1.5.2-beta` the output would be the following:
| Variable | Value |
| ----------------- | -------------- |
| GIT_VERSION_MAJOR | 1 |
| GIT_VERSION_MINOR | 5 |
| GIT_VERSION_BUILD | 2 |
| GIT_VERSION_TAIL | beta |
| GIT_COMMIT_COUNT | 10 |
| GIT_VER_STR | 1-5-2-beta |
| GIT_VER_SEM | v1.5.2-beta+10 |
| BUILD_TIMESTAMP_RFC | 1970-01-01T00:00:00Z |
| BUILD_TIMESTAMP_HR | 1970-01-01 00:00:00 UTC |

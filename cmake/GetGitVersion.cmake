cmake_minimum_required(VERSION 3.19)

find_package(Git REQUIRED)

macro(_export_git_version)
    string(JOIN "-" _git_ver_str ${_git_ver_major} ${_git_ver_minor} ${_git_ver_build} ${_git_ver_tail})
    string(JOIN "." _git_ver_sem ${_git_ver_major} ${_git_ver_minor} ${_git_ver_build} ${_git_ver_tail})

    set(GIT_VER_SEM "v${_git_ver_sem}" PARENT_SCOPE)
    set(GIT_VER_STR "${_git_ver_str}" PARENT_SCOPE)
    set(GIT_VER_MAJOR ${_git_ver_major} PARENT_SCOPE)
    set(GIT_VER_MINOR ${_git_ver_minor} PARENT_SCOPE)
    set(GIT_VER_BUILD ${_git_ver_build} PARENT_SCOPE)
    set(GIT_VER_TAIL "${_git_ver_tail}" PARENT_SCOPE)
    if(_git_commit_count)
        set(GIT_COMMIT_COUNT ${_git_commit_count} PARENT_SCOPE)
        set(GIT_VER_SEM "v${_git_ver_str}+${_git_commit_count}" PARENT_SCOPE)
    endif()

    message(VERBOSE "GIT_VER_STR: ${_git_ver_str}")
    message(VERBOSE "GIT_VER_MAJOR: ${_git_ver_major}")
    message(VERBOSE "GIT_VER_MINOR: ${_git_ver_minor}")
    message(VERBOSE "GIT_VER_BUILD: ${_git_ver_build}")
    message(VERBOSE "GIT_VER_TAIL: ${_git_ver_tail}")
endmacro()

## get_git_version_info
# This function attempts to parse a version string from the most recent git tag,
# expects tags in the form:
#
# <major>.<minor>.<patch>[-tail]
# prefixes will be ignored
#
# If no valid version tag exists or if git command fails, the function falls back to
# the default version:
# `0.0.0-dev`
#
# **Options**
#
# INCLUDE_COMMIT_COUNT
#   When provided, the function additionally gets the number of commits ahead of the 
#   version tag and exports it as `GIT_COMMIT_COUNT`. Additional the commits will be added
#   to the `GIT_VER_SEM`
#   If the commit count cannot be obtained or is 0, the variable is left unset.
#
# **Outputs**
#
# GIT_VERSION_MAJOR
#   Major number extracted from git tag
#
# GIT_VERSION_MINOR
#   Minor number extracted from git tag
#
# GIT_VERSION_BUILD
#   Build number extracted from git tag
#
# GIT_VERSION_TAIL
#   Tail extracted from git tag e.g. beta
#
# GIT_VER_STR
#   A human-readable version string constructed from the parsed components.
#   Format:
#      <major>-<minor>-<patch>[-<tail>]
#
# GIT_VER_SEM
#   A semantic version compatible version string constructed from the parsed components.
#   When `INCLUDE_COMMIT_COUNT` is enabled and a commit count is available the semantic string
#   included a build-metadata suffix
#   Format:
#      <major>-<minor>-<patch>[-<tail>][+<commit_count>]
#
# GIT_COMMIT_COUNT
#   number of the commits since the last version tag, only set with the option INCLUDE_COMMIT_COUNT
#   and additional commits existing
function (get_git_version_info)
    set(options "INCLUDE_COMMIT_COUNT")
    cmake_parse_arguments(_get_git_version "${options}" "" ""  ${ARGN})
    # Sets the default version information
    set(_git_ver_major 0)
    set(_git_ver_minor 0)
    set(_git_ver_build 0)
    set(_git_ver_tail "dev")

    # get git tag
    execute_process(
        COMMAND git describe --tags --abbrev=0
        WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
        OUTPUT_VARIABLE _git_describe
        RESULT_VARIABLE _exit_code
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    message(WARNING "${_git_describe}")

    # git describe failed (most likely no tag available) or produced an empty result, use default values
    if(NOT "${_exit_code}" EQUAL "0" AND "${_git_describe}" STREQUAL "")
        _export_git_version()
        return()
    endif()

    # matches 
    # 0.0.0
    # 0.0.0-anytext
    # there can be anytext before the version
    string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)(-(.+))?" _tag_match "${_git_describe}")        
    # no valid version found, use default values
    if (NOT _tag_match)
        _export_git_version()
        return()
    endif()

    set(_git_ver_major "${CMAKE_MATCH_1}")
    set(_git_ver_minor "${CMAKE_MATCH_2}")
    set(_git_ver_build "${CMAKE_MATCH_3}")
    set(_git_ver_tail "${CMAKE_MATCH_5}")

    if(_get_git_version_INCLUDE_COMMIT_COUNT)
        execute_process(
            COMMAND git rev-list "${_git_describe}..HEAD" --count
            WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
            OUTPUT_VARIABLE _git_commit_count
            RESULT_VARIABLE _exit_code
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        message(WARNING "${_git_describe} commit: ${_git_commit_count}")

        if(NOT ("${_exit_code}" EQUAL "0") AND ("${_git_commit_count}" GREATER "0"))
            unset(_git_commit_count)
        endif()
    endif()

   _export_git_version()
endfunction()

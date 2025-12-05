cmake_minimum_required(VERSION 3.19)

find_package(Git REQUIRED)

macro(_export_git_version)
    string(JOIN "-" _git_ver_str ${_git_ver_major} ${_git_ver_minor} ${_git_ver_patch} ${_git_ver_tail})
    string(JOIN "." _git_ver_sem ${_git_ver_major} ${_git_ver_minor} ${_git_ver_patch})
    string(JOIN "-" _git_ver_sem ${_git_ver_sem} ${_git_ver_tail})
    string(JOIN "," _git_ver_nnnn ${_git_ver_major} ${_git_ver_minor} ${_git_ver_patch} ${_git_ver_build})
    string(TIMESTAMP _build_timestamp_rfc UTC)
    string(TIMESTAMP _build_timestamp_hr "%Y-%m-%d %H:%M:%S UTC" UTC)

    set(GIT_VER_SEM "v${_git_ver_sem}" PARENT_SCOPE)
    set(GIT_VER_STR "${_git_ver_str}" PARENT_SCOPE)

    set(GIT_VER_MAJOR ${_git_ver_major} PARENT_SCOPE)
    set(GIT_VER_MINOR ${_git_ver_minor} PARENT_SCOPE)
    set(GIT_VER_PATCH ${_git_ver_patch} PARENT_SCOPE)
    set(GIT_VER_TAIL "${_git_ver_tail}" PARENT_SCOPE)
    set(GIT_VER_BUILD "${_git_ver_build}" PARENT_SCOPE)
    set(GIT_VER_NNNN "${_git_ver_nnnn}" PARENT_SCOPE)

    set(GIT_LONG_HASH "${_git_long_hash}" PARENT_SCOPE)
    set(GIT_SHORT_HASH "${_git_short_hash}" PARENT_SCOPE)

    set(GIT_AUTHOR_DATE "${_git_author_date}" PARENT_SCOPE)

    if(_git_commit_count AND _get_git_version_INCLUDE_COMMIT_COUNT)
        set(GIT_COMMIT_COUNT ${_git_commit_count} PARENT_SCOPE)
        set(GIT_VER_SEM "v${_git_ver_sem}+${_git_commit_count}" PARENT_SCOPE)
    endif()

    set(BUILD_TIMESTAMP_RFC ${_build_timestamp_rfc} PARENT_SCOPE)
    set(BUILD_TIMESTAMP_HR ${_build_timestamp_hr} PARENT_SCOPE)

    message(VERBOSE "GIT_VER_SEM: ${_git_ver_sem}")
    message(VERBOSE "GIT_VER_STR: ${_git_ver_str}")

    message(VERBOSE "GIT_VER_MAJOR: ${_git_ver_major}")
    message(VERBOSE "GIT_VER_MINOR: ${_git_ver_minor}")
    message(VERBOSE "GIT_VER_PATCH: ${_git_ver_patch}")
    message(VERBOSE "GIT_VER_TAIL: ${_git_ver_tail}")
    message(VERBOSE "GIT_VER_BUILD: ${_git_ver_build}")
    message(VERBOSE "GIT_VER_NNNN: ${_git_ver_nnnn}")

    message(VERBOSE "GIT_LONG_HASH: ${_git_long_hash}")
    message(VERBOSE "GIT_SHORT_HASH: ${_git_short_hash}")

    message(VERBOSE "BUILD_TIMESTAMP_RFC: ${_build_timestamp_rfc}")
    message(VERBOSE "BUILD_TIMESTAMP_HR: ${_build_timestamp_hr}")

    message(VERBOSE "GIT_AUTHOR_DATE: ${_git_author_date}")
endmacro()


## _git_makequad
# Internal function
#   Compute an "quad" build number derived from a git version tail (like alpha.1, beta.2, or plain "3")
#   and the additional-commits
#
# Parameters:
#   _git_ver_tail               - string containing the tail version to parse.
#
#   _git_additional_commits     - integer number of commits since last tag
#
# Output:
#   Sets _git_ver_build to an integer value containing the type + <build> * 100 + additional_commits
#
# Encoded bases:
#   alpha   -> 10000+
#   beta    -> 20000+
#   rc      -> 30000+
#   release -> 50000+
#
# Examples:
#   - v1.0.0-alpha                -> 10000
#   - v1.0.0-alpha.1              -> 10100
#   - v1.0.0-alpha.1 + 7 commits  -> 10107
#   - v1.0.0-rc.5                 -> 30500
#   - v1.0.0                      -> 50000
#   - v1.0.0.5                    -> 50500
function(_git_makequad _git_ver_tail _git_additional_commits)
    set(_alpha_base 10000)
    set(_beta_base 20000)
    set(_rc_base 30000)
    set(_release_base 50000)

    #rc-5
    #beta-10
    # match 1 -> name.
    # match 2 -> name
    # match 3 -> number
    string(REGEX MATCH "(([A-Za-z]+)\\.)?([0-9]+)" _tag_match "${_git_ver_tail}")

    if(NOT _tag_match)
        MATH(EXPR _build_quad "${_release_base} + ${_git_additional_commits}" )
        set(_git_ver_build "${_build_quad}" PARENT_SCOPE)
        return()
    endif()

    if("${CMAKE_MATCH_3}" STREQUAL "")
        set(_build "0")
    elseif("${CMAKE_MATCH_3}" GREATER 99)
        message(WARNING "Can't generate git quad version number is greater then 99")
    else()
        MATH(EXPR _build "${CMAKE_MATCH_3} * 100")
    endif()

    if("${CMAKE_MATCH_2}" STREQUAL "")
        set(_type ${_release_base})
    elseif("${CMAKE_MATCH_2}" STREQUAL "alpha" OR "${CMAKE_MATCH_2}" STREQUAL "a")
        set(_type "${_alpha_base}")
    elseif("${CMAKE_MATCH_2}" STREQUAL "beta" OR "${CMAKE_MATCH_2}" STREQUAL "b")
        set(_type "${_beta_base}")
    elseif("${CMAKE_MATCH_2}" STREQUAL "rc")
        set(_type ${_rc_base})
    else()
        message(WARNING "Can't generate git quad unknown tail: ${_git_ver_tail}")
        return()
    endif()

    MATH(EXPR _build_quad "${_type} + ${_build} + ${_git_additional_commits}")
    set(_git_ver_build "${_build_quad}" PARENT_SCOPE)
endfunction()

## _get_git_additional_commits
# Internal function
#   Gets the additional commits since the specific tag
#
# Parameters:
#   _git_tag    - string containing the last git tag
#
# Output
#   _git_commit_count with the number of additional commits
function(_get_git_additional_commits _git_tag)
    set(_git_commit_count 0)
    execute_process(
        COMMAND
             git rev-list "${_git_tag}..HEAD" --count
        WORKING_DIRECTORY
            "${PROJECT_SOURCE_DIR}"
        OUTPUT_VARIABLE
            _git_commit_count
        RESULT_VARIABLE
            _exit_code
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(NOT ("${_exit_code}" EQUAL "0"))
        message(WARNING "could not get additional commits git failed with exit code ${_exit_code}")
    endif()

    set(_git_commit_count "${_git_commit_count}" PARENT_SCOPE)
endfunction()

## _get_git_hash
# Internal function
#   Gets the short and long hash of the last commit
#
# Output
#   _git_long_hash  - the long hash
#   _git_short_hash - the short hash
function(_get_git_hash)
    execute_process(
        COMMAND git rev-parse HEAD
        WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
        OUTPUT_VARIABLE _git_long_hash
        RESULT_VARIABLE _exit_code
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(NOT ("${_exit_code}" EQUAL "0"))
        message(WARNING "could not get hash git failed with exit code ${_exit_code}")
    endif()

    execute_process(
        COMMAND git rev-parse --short HEAD
        WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
        OUTPUT_VARIABLE _git_short_hash
        RESULT_VARIABLE _exit_code
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(NOT ("${_exit_code}" EQUAL "0"))
        message(WARNING "could not get hash git failed with exit code ${_exit_code}")
    endif()

    set(_git_long_hash "${_git_long_hash}" PARENT_SCOPE)
    set(_git_short_hash "${_git_short_hash}" PARENT_SCOPE)
endfunction()

function(_get_git_author_date)
    execute_process(
        COMMAND
            git log -n1 --date=format:%Y-%m%dT%H:%M:%S --format=%ad
         WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
        OUTPUT_VARIABLE _git_author_date
        RESULT_VARIABLE _exit_code
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(NOT ("${_exit_code}" EQUAL "0"))
        message(WARNING "could not get hash git failed with exit code ${_exit_code}")
    endif()

    set(_git_author_date "${_git_author_date}" PARENT_SCOPE)
endfunction()

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
# GIT_VERSION_PATCH
#   Patch number extracted from git tag
#
# GIT_VERSION_BUILD
#   Quad generated number containing the build type (release, beta, alpha, rc) the build number
#   and additional commits
#
# GIT_VERSION_TAIL
#   Tail extracted from git tag e.g. beta
#
# GIT_LONG_HASH
#   Long hash of the last commit
#
# GIT_SHORT_HASH
#   Short hash of the last commit
#
# GIT_AUTHOR_DATE
#   Date of the last commit
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
#
# BUILD_TIMESTAMP_RFC
#   contains the build timestamp in RFC-3339 format, expressed in Coordinated Universal Time (UTC).
#
# BUILD_TIMESTAMP_HR
#   contains the build timestamp in a human readable format, expressed in Coordinated Universal Time (UTC).
function (get_git_version_info)
    set(options "INCLUDE_COMMIT_COUNT")
    cmake_parse_arguments(_get_git_version "${options}" "" ""  ${ARGN})
    # Sets the default version information
    set(_git_ver_major 0)
    set(_git_ver_minor 0)
    set(_git_ver_patch 0)
    set(_git_ver_tail "dev")

    _get_git_hash()
    _get_git_author_date()

    # get git tag
    execute_process(
        COMMAND git describe --tags --abbrev=0
        WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
        OUTPUT_VARIABLE _git_describe
        RESULT_VARIABLE _exit_code
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    message(VERBOSE "Git Describe return: ${_git_describe}")

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
    set(_git_ver_patch "${CMAKE_MATCH_3}")
    set(_git_ver_tail "${CMAKE_MATCH_5}")

    _get_git_additional_commits("${_git_describe}")
    _git_makequad("${_git_ver_tail}" "${_git_commit_count}")

   _export_git_version()
endfunction()

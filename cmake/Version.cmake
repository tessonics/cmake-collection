## make_version
# This function generates a version header file for a given target.
#
# Arguments:
#   TARGET: The name of the target for which the version header should be generated.
#
#   OUTPUT_FOLDER: folder to where the generated version header file should be saved defaults to
#                   ${CMAKE_CURRENT_BINARY_DIR}
#
#   OUTPUT_FILE: filename that the generated version header file should have defaults to
#                   ${TARGET}_version.h
#
# Options:
#   FORCE_RUN_GETGITVERSION - If set GetGitVersion runs whether it already run or not
#
#   DISABLE_INCLUDE_DIRECTORY - If set the OUTPUT_FOLDER will not be set as an include directory
function(make_version)
    set(options FORCE_RUN_GETGITVERSION DISABLE_INCLUDE_DIRECTORY)
    set(oneValueArgs TARGET OUTPUT_FOLDER OUTPUT_FILE)
    cmake_parse_arguments(_make_version "${options}" "${oneValueArgs}" "" ${ARGN})

    if(NOT GIT_VER_SEM OR _make_version_FORCE_RUN_GETGITVERSION)
        include(GetGitVersion)
        get_git_version_info()
    endif()

    if(_make_version_OUTPUT_FOLDER)
        set(_output_folder "${_make_version_OUTPUT_FOLDER}")
    else()
        set(_output_folder "${CMAKE_CURRENT_BINARY_DIR}")
    endif()

    if(_make_version_OUTPUT_FILE)
        set(_output_file "${_make_version_OUTPUT_FILE}")
    elseif(_make_version_TARGET)
        set(_output_file "${_make_version_TARGET}_version.h")
    else()
        set(_output_file "version.h")
    endif()

    message(STATUS "${_make_version_TARGET}: Generating version header")

    configure_file(
        "${__CMAKE_SCRIPTS_MAKE_VERSION_FOLDER_DIR}/../version.h.in"
        "${_output_folder}/${_output_file}"
    )

    if(NOT _make_version_DISABLE_INCLUDE_DIRECTORY AND _make_version_TARGET)
        target_include_directories(${_make_version_TARGET} PUBLIC "${_output_folder}")
    endif()
    message(STATUS "${_make_version_TARGET}: product version ${GIT_VER_SEM}")
endfunction()

set(__CMAKE_SCRIPTS_MAKE_VERSION_FOLDER_DIR "${CMAKE_CURRENT_LIST_DIR}")

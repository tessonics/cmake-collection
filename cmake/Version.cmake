## make_version
# This function generates a version header file for a given target.
#
# Arguments:
#   target_name: The name of the target for which the version header will be generated.
function(make_version target_name)
    set(options FORCE_RUN_GETGITVERSION DISABLE_INCLUDE_DIRECTORY)
    set(oneValueArgs OUTPUT_FOLDER OUTPUT_FILE)
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
    else()
        set(_output_file "${target_name}_version.h")
    endif()


    message(STATUS "${target_name}: Generating version header")
    configure_file(
        "${__CMAKE_SCRIPTS_MAKE_VERSION_FOLDER_DIR}/../version.h.in"
        "${_output_folder}/${_output_file}"
    )

    if(NOT _make_version_DISABLE_INCLUDE_DIRECTORY)
        target_include_directories(${target_name} PUBLIC "${CMAKE_CURRENT_BINARY_DIR}")
    endif()
    message(STATUS "${target_name}: product version ${GIT_VER_SEMANTIC}")
endfunction()

set(__CMAKE_SCRIPTS_MAKE_VERSION_FOLDER_DIR "${CMAKE_CURRENT_LIST_DIR}")

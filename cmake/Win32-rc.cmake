function(make_windows_rc)
    set(options "FORCE_RUN_GETGITVERSION")
    set(oneValueArgs "TARGET" "OUTPUT_FOLDER" "OUTPUT_FILE")
    cmake_parse_arguments(_make_windows_rc "${options}" "${oneValueArgs}" "" ${ARGN})

    if(NOT GIT_VER_SEM OR _make_windows_rc_FORCE_RUN_GETGITVERSION)
        include(GetGitVersion)
        get_git_version_info()
    endif()

    if(_make_windows_rc_OUTPUT_FOLDER)
        set(_output_folder "${_make_windows_rc_OUTPUT_FOLDER}")
    else()
        set(_output_folder "${CMAKE_CURRENT_BINARY_DIR}")
    endif()

    if(_make_windows_rc_OUTPUT_FILE)
        set(_output_file "${_make_windows_rc_OUTPUT_FILE}")
    elseif(_make_windows_rc_TARGET)
        set(_output_file "${_make_windows_rc_TARGET}.rc")
    else()
        set(_output_file "windows.rc")
    endif()

    message(STATUS "${_make_windows_rc_TARGET}: Generating Windows resource file")

    get_target_property(_target_type "${_make_windows_rc_TARGET}" TYPE)
    if(_target_type STREQUAL "EXECUTABLE")
        set(_target_type "VFT_APP")
    elseif(_target_type STREQUAL "STATIC_LIBRARY")
        set(_target_type " VFT_STATIC_LIB")
    elseif(_target_type STREQUAL "SHARED_LIBRARY")
        set(_target_type "VFT_DLL")
    else()
        message(FATAL_ERROR "Cannot generate Windows resource file for target type: ${_target_type}")
    endif()

    if(GIT_VER_BUILD MATCHES "^5")
        set(_fileflags 0) # No flag for release builds
    else()
        set(_fileflags "VS_FF_PRERELEASE")
        # could use  VS_FF_PRIVATEBUILD & VS_FF_SPECIALBUILD for alpha / beta but would need to add a way to set the Info Strings
    endif()

    if(_DEBUG)
        set(_fileflags "${_fileflags} | VS_FF_DEBUG")
    endif()


    configure_file(
        "${__CMAKE_SCRIPTS_MAKE_VERSION_FOLDER_DIR}/../windows.rc.in"
        "${_output_folder}/${_output_file}"
    )

endfunction()

# Need to set the variable when the cmake file gets first loaded, so that the configure_file() calls in the functions above can find the .in files.
set(__CMAKE_SCRIPTS_MAKE_VERSION_FOLDER_DIR "${CMAKE_CURRENT_LIST_DIR}")

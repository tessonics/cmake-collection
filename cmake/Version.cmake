## make_version
# This function generates a version header file for a given target.
#
# Arguments:
#   target_name: The name of the target for which the version header will be generated.
function(make_version target_name)
    include(GetGitVersion)
    message(STATUS "${target_name}: Generating version header")
    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/version.h.in"
        "${CMAKE_CURRENT_BINARY_DIR}/${target_name}_version.h"
    )

    target_include_directories(${target_name} PUBLIC "${CMAKE_CURRENT_BINARY_DIR}")
    message(STATUS "${target_name}: product version ${GIT_VER_SEMANTIC}")
endfunction()

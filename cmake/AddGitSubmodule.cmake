# Source https://gist.github.com/scivision/bb1d47a9529e153617414e91ff5390af

find_package(Git REQUIRED)

## add_git_submodule 
# This functions adds a Git submodule directory to CMake, assuming
# the directory is a CMake project.
# If the directory does not contain a CMakeLists.txt 
# git submodule update --init --recursive 
# will be executed
#
# Parameters
#   dir              - (IN) The path to the folder
function(add_git_submodule dir)
    if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${dir}/CMakeLists.txt)
    execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive -- ${CMAKE_CURRENT_SOURCE_DIR}/${dir}
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
        COMMAND_ERROR_IS_FATAL ANY)
    endif()

    add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/${dir})

endfunction(add_git_submodule)

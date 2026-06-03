cmake_minimum_required(VERSION 3.25)

find_package(Git REQUIRED)

if(NOT GIT_FOUND)
    message(FATAL_ERROR "Git is required to clone repositories. Please install Git and try again.")
endif()
 
# Version overrides: set via -D or environment for CI/release builds
# e.g: cmake -DCORE_VERSION=v4.0.1 -P setup.cmake
set(CORE_VERSION       $ENV{CORE_VERSION})
set(REDASM_VERSION     $ENV{REDASM_VERSION})
set(LOADERS_VERSION    $ENV{LOADERS_VERSION})
set(PROCESSORS_VERSION $ENV{PROCESSORS_VERSION})
set(COMMANDS_VERSION   $ENV{COMMANDS_VERSION})
set(ANALYZERS_VERSION  $ENV{ANALYZERS_VERSION})
set(KB_VERSION         $ENV{KB_VERSION})
 
# Allow -D overrides to take precedence over environment
if(NOT CORE_VERSION)
    set(CORE_VERSION "master")
endif()
if(NOT REDASM_VERSION)
    set(REDASM_VERSION "master")
endif()
if(NOT LOADERS_VERSION)
    set(LOADERS_VERSION "master")
endif()
if(NOT PROCESSORS_VERSION)
    set(PROCESSORS_VERSION "master")
endif()
if(NOT COMMANDS_VERSION)
    set(COMMANDS_VERSION "master")
endif()
if(NOT ANALYZERS_VERSION)
    set(ANALYZERS_VERSION "master")
endif()
if(NOT KB_VERSION)
    set(KB_VERSION "master")
endif()
 
set(BASE_URL "https://github.com/redasm-dev")
 
# Map repo name -> version
set(REPO_core       ${CORE_VERSION})
set(REPO_redasm     ${REDASM_VERSION})
set(REPO_loaders    ${LOADERS_VERSION})
set(REPO_processors ${PROCESSORS_VERSION})
set(REPO_commands   ${COMMANDS_VERSION})
set(REPO_analyzers  ${ANALYZERS_VERSION})
set(REPO_kb         ${KB_VERSION})
 
set(REPOS core redasm loaders processors commands analyzers kb)
 
foreach(repo ${REPOS})
    set(version ${REPO_${repo}})
    set(dest "${CMAKE_CURRENT_LIST_DIR}/${repo}")
 
    if(EXISTS "${dest}/.git")
        message(STATUS "[${repo}] updating to ${version}...")

        execute_process(
            COMMAND ${GIT_EXECUTABLE} -C "${dest}" fetch --quiet
            RESULT_VARIABLE result
        )

        if(NOT result EQUAL 0)
            message(FATAL_ERROR "Failed to fetch ${repo}. Aborting.")
        endif()

        execute_process(
            COMMAND ${GIT_EXECUTABLE} -C "${dest}" checkout "${version}" --quiet 
            RESULT_VARIABLE result
        )

        if(NOT result EQUAL 0)
            message(FATAL_ERROR "Failed to checkout ${version} for ${repo}. Aborting.")
        endif()
    else()
        message(STATUS "[${repo}] cloning @ ${version}...")

        execute_process(
            COMMAND ${GIT_EXECUTABLE} clone --branch "${version}" --progress "${BASE_URL}/${repo}" "${dest}"
            RESULT_VARIABLE result
        )

        if(NOT result EQUAL 0)
            message(FATAL_ERROR "Failed to clone ${repo}. Aborting.")
        endif()
    endif()
endforeach()
 
message(STATUS "Done. Now run:")
message(STATUS "  cmake -B build")
message(STATUS "  cmake --build build")

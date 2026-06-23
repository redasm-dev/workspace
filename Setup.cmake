cmake_minimum_required(VERSION 3.25)

find_package(Git REQUIRED)

if(NOT GIT_FOUND)
    message(FATAL_ERROR "Git is required to clone repositories. Please install Git and try again.")
endif()
 
if(NOT DEFINED REDASM_FETCH_TESTS)
    set(REDASM_FETCH_TESTS OFF)
endif()

if(NOT DEFINED REDASM_SHALLOW)
    set(REDASM_SHALLOW OFF)
endif()

if(REDASM_SHALLOW)
    set(depth_arg "--depth=1")
else()
    set(depth_arg "")
endif()

# Base version: applies to every repo unless overridden individually below.
# e.g: cmake -DREDASM_VERSION_DEFAULT=v4.0.1 -P Setup.cmake
if(NOT DEFINED REDASM_VERSION_DEFAULT)
    set(REDASM_VERSION_DEFAULT $ENV{REDASM_VERSION_DEFAULT})
endif()

if(NOT REDASM_VERSION_DEFAULT)
    set(REDASM_VERSION_DEFAULT "master")
endif()

# Per component version overrides: set via -D or environment for CI/release builds
# e.g: cmake -DCORE_VERSION=v4.0.1 -P setup.cmake
set(CORE_VERSION       $ENV{CORE_VERSION})
set(GUI_VERSION        $ENV{GUI_VERSION})
set(LOADERS_VERSION    $ENV{LOADERS_VERSION})
set(PROCESSORS_VERSION $ENV{PROCESSORS_VERSION})
set(COMMANDS_VERSION   $ENV{COMMANDS_VERSION})
set(ANALYZERS_VERSION  $ENV{ANALYZERS_VERSION})
 
# Allow -D overrides to take precedence over environment
# unset falls back to the shared default rather than a hardcoded "master".
if(NOT CORE_VERSION)
    set(CORE_VERSION "${REDASM_VERSION_DEFAULT}")
endif()
if(NOT GUI_VERSION)
    set(GUI_VERSION "${REDASM_VERSION_DEFAULT}")
endif()
if(NOT LOADERS_VERSION)
    set(LOADERS_VERSION "${REDASM_VERSION_DEFAULT}")
endif()
if(NOT PROCESSORS_VERSION)
    set(PROCESSORS_VERSION "${REDASM_VERSION_DEFAULT}")
endif()
if(NOT COMMANDS_VERSION)
    set(COMMANDS_VERSION "${REDASM_VERSION_DEFAULT}")
endif()
if(NOT ANALYZERS_VERSION)
    set(ANALYZERS_VERSION "${REDASM_VERSION_DEFAULT}")
endif()
if(NOT KB_VERSION)
    set(KB_VERSION "master")
endif()
 
set(BASE_URL "https://github.com/redasm-dev")
 
# Map repo name -> version
set(REPO_core       ${CORE_VERSION})
set(REPO_redasm     ${GUI_VERSION})
set(REPO_loaders    ${LOADERS_VERSION})
set(REPO_processors ${PROCESSORS_VERSION})
set(REPO_commands   ${COMMANDS_VERSION})
set(REPO_analyzers  ${ANALYZERS_VERSION})
set(REPO_kb         ${KB_VERSION})
set(REPO_tests      "master")  # no tagging here
set(REPO_samples    "master")  # no tagging here
 
set(REPOS 
    core 
    redasm
    loaders 
    processors 
    commands 
    analyzers
    kb
)

if(REDASM_FETCH_TESTS)
    list(APPEND REPOS tests)
    list(APPEND REPOS samples)
endif()
 
foreach(repo ${REPOS})
    set(version ${REPO_${repo}})
    set(dest "${CMAKE_CURRENT_LIST_DIR}/${repo}")
 
    if(EXISTS "${dest}/.git")
        message(STATUS "[${repo}] updating to ${version}...")

        execute_process(
            COMMAND ${GIT_EXECUTABLE} -C "${dest}" pull --ff-only
            RESULT_VARIABLE result
        )
        if(NOT result EQUAL 0)
            message(FATAL_ERROR "Failed to update ${repo}: local changes or diverged branch. Aborting.")
        endif()
    else()
        message(STATUS "[${repo}] cloning @ ${version}...")

        execute_process(
            COMMAND ${GIT_EXECUTABLE} clone ${depth_arg} --branch "${version}" --progress "${BASE_URL}/${repo}" "${dest}"
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

cmake_minimum_required(VERSION 3.25)

project(redasm-workspace C CXX)

if(WIN32)
    set(CMAKE_INSTALL_BINDIR ".")
    set(CMAKE_INSTALL_LIBDIR ".")
    set(CMAKE_INSTALL_DATADIR ".")
    set(CMAKE_INSTALL_INCLUDEDIR "include")

    set(REDASM_INSTALL_PLUGINS "plugins/${type}")
    set(REDASM_INSTALL_KB "kb")
else()
    include(GNUInstallDirs)
    set(REDASM_INSTALL_PLUGINS "${CMAKE_INSTALL_LIBDIR}/redasm/plugins")
    set(REDASM_INSTALL_KB "${CMAKE_INSTALL_DATADIR}/redasm/kb")
endif()

add_subdirectory(core)
add_subdirectory(redasm)
add_subdirectory(loaders)
add_subdirectory(processors)
add_subdirectory(commands)

set(REDASM_PLUGIN_TYPES
    loaders
    processors
    commands
)

macro(redasm_stage target dest)
    add_custom_target(stage_${target} ALL
        COMMAND ${CMAKE_COMMAND} -E make_directory "${dest}"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different "$<TARGET_FILE:${target}>" "${dest}/"
        COMMENT "Staging ${target} -> ${dest}"
        DEPENDS ${target}
    )
endmacro()

redasm_stage(redasm "$<TARGET_FILE_DIR:redasm-gui>")

foreach(type ${REDASM_PLUGIN_TYPES})
    get_property(subdirs DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${type}" PROPERTY SUBDIRECTORIES)

    foreach(subdir ${subdirs})
        get_property(targets DIRECTORY ${subdir} PROPERTY BUILDSYSTEM_TARGETS)

        foreach(target ${targets})
            get_target_property(target_type ${target} TYPE)

            if(target_type STREQUAL "SHARED_LIBRARY")
                redasm_stage(${target} "$<TARGET_FILE_DIR:redasm-gui>/plugins/${type}")

                if(NOT WIN32)
                    set_target_properties(${target} PROPERTIES
                                          INSTALL_RPATH "$ORIGIN/../../../"
                    )
                endif()

                install(TARGETS ${target}
                        LIBRARY DESTINATION "${REDASM_INSTALL_PLUGINS}/${type}"
                        RUNTIME DESTINATION "${REDASM_INSTALL_PLUGINS}/${type}"
                )
            endif()
        endforeach()
    endforeach()
endforeach()

add_custom_target(stage_kb ALL
    COMMAND ${CMAKE_COMMAND} -E copy_directory "${CMAKE_CURRENT_SOURCE_DIR}/kb" "$<TARGET_FILE_DIR:redasm-gui>/kb"
    COMMENT "Staging kb -> $<TARGET_FILE_DIR:redasm-gui>/kb/"
)

install(
    DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/kb/"
    DESTINATION ${REDASM_INSTALL_KB}
    FILES_MATCHING
            PATTERN "*.toml"
            PATTERN ".*" EXCLUDE
)

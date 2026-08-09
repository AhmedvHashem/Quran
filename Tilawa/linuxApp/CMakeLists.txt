cmake_minimum_required(VERSION 3.20)
project(TilawaLinux CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(PkgConfig REQUIRED)
pkg_check_modules(GTKMM REQUIRED IMPORTED_TARGET gtkmm-4.0)
pkg_check_modules(ADWAITA REQUIRED IMPORTED_TARGET libadwaita-1)

# KMP shared core (C ABI, see .agents/skills/kmp-c-abi + kmp-linux-bridge).
if(WIN32)
    set(KMP_TARGET "mingwX64")
    set(GRADLE_TASK ":shared:linkReleaseSharedMingwX64")
    set(LIB_NAME "Shared.dll")
elseif(APPLE)
    if(CMAKE_SYSTEM_PROCESSOR MATCHES "arm64|aarch64")
        set(KMP_TARGET "macosArm64")
        set(GRADLE_TASK ":shared:linkReleaseSharedMacosArm64")
    else()
        set(KMP_TARGET "macosX64")
        set(GRADLE_TASK ":shared:linkReleaseSharedMacosX64")
    endif()
    set(LIB_NAME "libShared.dylib")
else()
    set(KMP_TARGET "linuxX64")
    set(GRADLE_TASK ":shared:linkReleaseSharedLinuxX64")
    set(LIB_NAME "libShared.so")
endif()

set(SHARED_BIN ${CMAKE_SOURCE_DIR}/../shared/build/bin/${KMP_TARGET}/releaseShared)
add_custom_command(
    OUTPUT ${SHARED_BIN}/${LIB_NAME}
    COMMAND ${CMAKE_SOURCE_DIR}/../gradlew ${GRADLE_TASK} -q
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/..
)
add_custom_target(shared-core DEPENDS ${SHARED_BIN}/${LIB_NAME})

add_library(Shared SHARED IMPORTED)
if(WIN32)
    set_target_properties(Shared PROPERTIES
        IMPORTED_LOCATION ${SHARED_BIN}/${LIB_NAME}
        IMPORTED_IMPLIB ${SHARED_BIN}/${LIB_NAME}
        INTERFACE_INCLUDE_DIRECTORIES ${SHARED_BIN})
else()
    set_target_properties(Shared PROPERTIES
        IMPORTED_LOCATION ${SHARED_BIN}/${LIB_NAME}
        INTERFACE_INCLUDE_DIRECTORIES ${SHARED_BIN})
endif()

add_executable(tilawa-linux src/main.cc)
add_dependencies(tilawa-linux shared-core)
target_link_libraries(tilawa-linux PRIVATE PkgConfig::GTKMM PkgConfig::ADWAITA Shared)
set_target_properties(tilawa-linux PROPERTIES BUILD_RPATH ${SHARED_BIN} INSTALL_RPATH ${SHARED_BIN})

if(WIN32)
    add_custom_command(TARGET tilawa-linux POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${SHARED_BIN}/${LIB_NAME}
            $<TARGET_FILE_DIR:tilawa-linux>)
endif()

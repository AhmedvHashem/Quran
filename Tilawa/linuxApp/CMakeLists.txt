cmake_minimum_required(VERSION 3.20)
project(TilawaLinux CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(PkgConfig REQUIRED)
pkg_check_modules(GTKMM REQUIRED IMPORTED_TARGET gtkmm-4.0)
pkg_check_modules(ADWAITA REQUIRED IMPORTED_TARGET libadwaita-1)

# KMP shared core (C ABI, see .opencode/skills/kmp-c-abi + gtk-linux-bridge).
# Built once via Gradle; re-run `../gradlew :shared:linkReleaseSharedLinuxX64` to refresh.
set(SHARED_BIN ${CMAKE_SOURCE_DIR}/../shared/build/bin/linuxX64/releaseShared)
add_custom_command(
    OUTPUT ${SHARED_BIN}/libShared.so
    COMMAND ${CMAKE_SOURCE_DIR}/../gradlew :shared:linkReleaseSharedLinuxX64 -q
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/..
)
add_custom_target(shared-core DEPENDS ${SHARED_BIN}/libShared.so)

add_library(Shared SHARED IMPORTED)
set_target_properties(Shared PROPERTIES
    IMPORTED_LOCATION ${SHARED_BIN}/libShared.so
    INTERFACE_INCLUDE_DIRECTORIES ${SHARED_BIN})

add_executable(tilawa-linux src/main.cc)
add_dependencies(tilawa-linux shared-core)
target_link_libraries(tilawa-linux PRIVATE PkgConfig::GTKMM PkgConfig::ADWAITA Shared)
set_target_properties(tilawa-linux PROPERTIES BUILD_RPATH ${SHARED_BIN})

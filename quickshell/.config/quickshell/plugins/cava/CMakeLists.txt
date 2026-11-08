cmake_minimum_required(VERSION 3.21)
project(qs-cava LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Qml)
find_package(PkgConfig REQUIRED)
pkg_check_modules(PIPEWIRE REQUIRED IMPORTED_TARGET libpipewire-0.3)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_qml_module(qscava
    URI Cava
    VERSION 1.0
    PLUGIN_TARGET qscava
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/Cava
    SOURCES cavaprovider.h cavaprovider.cpp
)

target_link_libraries(qscava PRIVATE Qt6::Qml PkgConfig::PIPEWIRE cava)

# installs to <prefix>/Cava; build.sh points this at ~/.local/lib/qt6/qml
install(TARGETS qscava LIBRARY DESTINATION Cava)
install(FILES ${CMAKE_BINARY_DIR}/Cava/qmldir ${CMAKE_BINARY_DIR}/Cava/qscava.qmltypes DESTINATION Cava)

cmake_minimum_required(VERSION 3.9)

project(main VERSION 0.1)

# Disable warnings
add_definitions(-w)

# Set C++ standard to C++23
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Add the source files for ImGui
add_library(imgui STATIC
  imgui/imgui.cpp
  imgui/imgui_widgets.cpp
  imgui/imgui_impl_opengl3.cpp
  imgui/imgui_impl_glfw.cpp
  imgui/imgui_draw.cpp
  imgui/imgui_tables.cpp
)

# Set the include directories for ImGui
target_include_directories(imgui PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}
)

# Find packages
find_package (X11 REQUIRED)

# Add additional libs
link_directories(/usr/local/lib)

# Add the executable target
add_executable(main Nika.cpp)

# Link the executable against the ImGui library, GLFW/OpenGL libraries and X11 libraries
target_link_libraries(main
  imgui
  glfw3
  GL
  X11
  Xinerama
  Xi
  udev
  ${X11_LIBRARIES}
  ${X11_XTest_LIB}
)

# Set the include directories for the executable
target_include_directories(main PUBLIC
  /usr/local/include
  ${CMAKE_CURRENT_SOURCE_DIR}/Utils
  ${CMAKE_CURRENT_SOURCE_DIR}/Core
  ${CMAKE_CURRENT_SOURCE_DIR}/Math
  ${CMAKE_CURRENT_SOURCE_DIR}/Features
  ${CMAKE_CURRENT_SOURCE_DIR}/Overlay
)

# Copy nika.ini to build folder
file(COPY ${CMAKE_SOURCE_DIR}/nika.ini DESTINATION ${CMAKE_BINARY_DIR})

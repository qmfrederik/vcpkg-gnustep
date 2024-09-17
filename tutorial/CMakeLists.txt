cmake_minimum_required(VERSION 3.10)

project(Tutorial)

find_package(GNUstep)

add_executable(Tutorial main.m)
target_link_libraries(Tutorial GNUstep::Base)

# Copy all of the GNUstep libraries to the output folder
target_copy_gnustep_libraries(Tutorial)

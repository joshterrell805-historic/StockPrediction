cmake_minimum_required(VERSION 2.6)
project(train)

add_executable(train train.c)
target_link_libraries(train fann)
target_link_libraries(train doublefann)
target_link_libraries(train m)

add_executable(eval eval.c)
target_link_libraries(eval fann)
target_link_libraries(eval doublefann)
target_link_libraries(eval m)

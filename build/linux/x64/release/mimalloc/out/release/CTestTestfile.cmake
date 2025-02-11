# CMake generated Testfile for 
# Source directory: /home/mia/Documents/nyaashows/build/linux/x64/release/mimalloc/mimalloc-2.1.2
# Build directory: /home/mia/Documents/nyaashows/build/linux/x64/release/mimalloc/out/release
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(test-api "/home/mia/Documents/nyaashows/build/linux/x64/release/mimalloc/out/release/mimalloc-test-api")
set_tests_properties(test-api PROPERTIES  _BACKTRACE_TRIPLES "/home/mia/Documents/nyaashows/build/linux/x64/release/mimalloc/mimalloc-2.1.2/CMakeLists.txt;506;add_test;/home/mia/Documents/nyaashows/build/linux/x64/release/mimalloc/mimalloc-2.1.2/CMakeLists.txt;0;")
add_test(test-api-fill "/home/mia/Documents/nyaashows/build/linux/x64/release/mimalloc/out/release/mimalloc-test-api-fill")
set_tests_properties(test-api-fill PROPERTIES  _BACKTRACE_TRIPLES "/home/mia/Documents/nyaashows/build/linux/x64/release/mimalloc/mimalloc-2.1.2/CMakeLists.txt;506;add_test;/home/mia/Documents/nyaashows/build/linux/x64/release/mimalloc/mimalloc-2.1.2/CMakeLists.txt;0;")
add_test(test-stress "/home/mia/Documents/nyaashows/build/linux/x64/release/mimalloc/out/release/mimalloc-test-stress")
set_tests_properties(test-stress PROPERTIES  _BACKTRACE_TRIPLES "/home/mia/Documents/nyaashows/build/linux/x64/release/mimalloc/mimalloc-2.1.2/CMakeLists.txt;506;add_test;/home/mia/Documents/nyaashows/build/linux/x64/release/mimalloc/mimalloc-2.1.2/CMakeLists.txt;0;")

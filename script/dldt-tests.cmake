file(GLOB tests "${CMAKE_CURRENT_SOURCE_DIR}/../../../test/dldt_*.sh")
foreach(test ${tests})
    get_filename_component(name ${test} NAME_WE)
    add_test(test_${image}_${name} "${CMAKE_CURRENT_SOURCE_DIR}/shell.sh" "/mnt/${name}.sh" "${image}")
endforeach()

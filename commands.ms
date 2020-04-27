proc _private_util_get_all_tests(@path) {
    @files = array()
    @list_files = list_files(@path)
    foreach(@file in @list_files) {
        if (is_dir(@file)) {
            array_push(@files, _private_get_all_tests(@file))
        } else {
            array(@files, @file)
        }
    }
    return(@files)
}

proc _package_unit_create_setting(string @path_to_setting, string @path_to_test) {
    console('CHUnit: creating '.@path_to_setting.' ...')
    @files = array_sort(_private_get_all_tests(@path_to_test), 'STRING')
    @prop = _new_properties_object()
    foreach(@file in @files) {
        execute(@file, "", @prop['pull'])
    }
    write_file(@path_to_setting, execute(@prop['to_string'], 'OVERWRITE'))
    console('CHUnit: '.@path_to_setting.' created')
    console('CHUnit: finish')
}
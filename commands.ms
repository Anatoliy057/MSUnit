proc _private_util_get_all_tests(@path) {
    @files = array()
    @list_files = list_files(@path)
    foreach(@file in @list_files) {
        if (string_contains(@file, '.')) {
            @pref = replace(@path, '/', '.')
            if (string_contains(@file, '.ms'), array_push(@files, @pref.'.'.@file))
        } else {
            array_push_all(@files, _private_util_get_all_tests(@path.'/'.@file))
        }
    }
    return(@files)
}

proc _package_unit_create_setting(string @path_to_setting, string @path_to_test) {
    console('CHUnit: creating '.@path_to_setting.' ...')
    @files = array_sort(_private_util_get_all_tests(@path_to_test), 'STRING')
    @prop = _util_new_properties_object()
    foreach(@file in @files) {
        execute(@file, "", @prop['push'])
    }
    if (!file_exists(@path_to_setting), create_file(@path_to_setting))
    write_file(@path_to_setting, execute(@prop['to_string']), 'OVERWRITE')
    console('CHUnit: '.@path_to_setting.' created')
}

proc _package_unit_update_setting(string @path_to_setting, string @path_to_test) {
    console('CHUnit: updating '.@path_to_setting.'...')
    if (!file_exists(@path_to_setting)) {
        console('CHUnit: File '.@path_to_setting.' of setting doesn\'t exist')
        console('CHUnit: Sure that path is correct or start command:')
        console('CHUnit: /unit '.@UNIT_DEFAULT_COMMAND_PREFIX.@UNIT_DEFAULT_COMMAND_INIT)
        return()
    }
    @prop = _util_new_properties_object()
    execute(read(@path_to_setting), @prop['parse_string'])
    @files = array_sort(_private_util_get_all_tests(@path_to_test), 'STRING')
    for(@i = 0, @i < array_size(@files), @i++) {
        if (!execute(@files[@i], @prop['contains']), execute(@files[@i], "", @prop['push']))
    }
    write_file(@path_to_setting, execute(@prop['to_string']), 'OVERWRITE')
    console('CHUnit: '.@path_to_setting.' updated')
}

proc _package_unit_start_test(@output, @groups) {
    console('CHUnit: starting '.@path_to_setting.'...')
    console('CHUnit: arguments: '.@arguments)
    console('CHUnit: finish testing')
}
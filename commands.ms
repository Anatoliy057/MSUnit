proc _package_unit_create_setting(string @path_to_setting, string @path_to_test) {
    console('CHUnit: creating '.@path_to_setting.' ...')
    @len_pref = length(get_absolute_path(@path_to_test)) - length(@path_to_test)
    @files = array_sort(_util_get_all_scripts(get_absolute_path(@path_to_test)), 'STRING')
    @prop = _util_properties_init_self()
    foreach(@file in @files) {
        _util_properties_push(
            @prop,
            replace(@file[cslice(@len_pref, -1)], '\\', '.'),
            ""
        )
    }
    if (!file_exists(@path_to_setting), create_file(@path_to_setting))
    write_file(@path_to_setting, _util_properties_to_string(@prop), 'OVERWRITE')
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
    @prop = _util_properties_init_self()
    _util_properties_parse_string(@prop, read(@path_to_setting))
    @len_pref = length(get_absolute_path(@path_to_test)) - length(@path_to_test)
    @files = array_sort(_util_get_all_scripts(get_absolute_path(@path_to_test)), 'STRING')
    for (@i = 0, @i < array_size(@files), @i++) {
        @file = replace(@files[@i][cslice(@len_pref, -1)], '\\', '.')
        if (!_util_properties_contains(@prop, @file), _util_properties_push(@prop, @file, ""))
    }
    write_file(@path_to_setting, _util_properties_to_string(@prop), 'OVERWRITE')
    console('CHUnit: '.@path_to_setting.' updated')
}

proc _package_unit_start_test(@output, @groups) {
    console('CHUnit: starting '.@path_to_setting.'...')
    console('CHUnit: arguments: '.@arguments)
    console('CHUnit: finish testing')
}
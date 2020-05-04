proc _package_unit_create_setting(string @path_to_groups, string @path_to_test, string @def_value) {
    console('CHUnit: creating '.@path_to_groups.' ...')
    @len_pref = length(get_absolute_path(@path_to_test)) - length(@path_to_test)
    @files = array_sort(_util_get_all_scripts(get_absolute_path(@path_to_test)), 'STRING')
    @prop = _util_properties_init_self()
    foreach(@file in @files) {
        _util_properties_push(
            @prop,
            replace(replace(@file[cslice(@len_pref, -1)], '\\', '.'), '.ms', ''),
            @def_value
        )
    }
    if (!file_exists(@path_to_groups), create_file(@path_to_groups))
    write_file(@path_to_groups, _util_properties_to_string(@prop), 'OVERWRITE')
    console('CHUnit: '.@path_to_groups.' created')
}

proc _package_unit_update_setting(string @path_to_groups, string @path_to_test, string @def_value) {
    console('CHUnit: updating '.@path_to_groups.'...')
    if (!file_exists(@path_to_groups)) {
        console(_package_unit_get_msg('setting_groups_not_found'))
    }
    @prop = _util_properties_init_self()
    _util_properties_parse_string(@prop, read(@path_to_groups))
    @len_pref = length(get_absolute_path(@path_to_test)) - length(@path_to_test)
    @files = array_sort(_util_get_all_scripts(get_absolute_path(@path_to_test)), 'STRING')
    for (@i = 0, @i < array_size(@files), @i++) {
        @file = replace(replace(@files[@i][cslice(@len_pref, -1)], '\\', '.'), '.ms', '')
        if (!_util_properties_contains(@prop, @file), _util_properties_push(@prop, @file, @def_value))
    }
    write_file(@path_to_groups, _util_properties_to_string(@prop), 'OVERWRITE')
    console('CHUnit: '.@path_to_groups.' updated')
}

proc _package_unit_start_test(@path_to_groups, @setting, @groups, @del_groups) {
    console('CHUnit: starting tests...')
    @prop = _util_properties_init_self()
    if (array_size(@arguments) < 5) {
        console(_package_unit_get_msg('setting_out_not_found'))
    }
    if (!file_exists(@path_to_groups)) {
        console(_package_unit_get_msg('setting_groups_not_found'), @path_to_groups)
    }
    _util_properties_parse_string(@prop, read(@path_to_groups))
    @tests = array()

    foreach(@file: @str_group in _util_properties_to_map(@prop)) {
        if (_util_array_some_contains(split(@del_groups, @str_group), @groups)) {
            array_push(@tests, @file)
        }
    }

    @out = array()
    for(@i = 4, @i < array_size(@arguments), @i++) {
        array_push(@out, @arguments[@i])
    }
    _package_unit_do_tests(@tests, @setting, @out)
}
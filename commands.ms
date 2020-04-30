proc _package_unit_create_setting(string @path_to_set_groups, string @path_to_test) {
    console('CHUnit: creating '.@path_to_set_groups.' ...')
    @len_pref = length(get_absolute_path(@path_to_test)) - length(@path_to_test)
    @files = array_sort(_util_get_all_scripts(get_absolute_path(@path_to_test)), 'STRING')
    @prop = _util_properties_init_self()
    foreach(@file in @files) {
        _util_properties_push(
            @prop,
            replace(replace(@file[cslice(@len_pref, -1)], '\\', '.'), '.ms', ''),
            ""
        )
    }
    if (!file_exists(@path_to_set_groups), create_file(@path_to_set_groups))
    write_file(@path_to_set_groups, _util_properties_to_string(@prop), 'OVERWRITE')
    console('CHUnit: '.@path_to_set_groups.' created')
}

proc _package_unit_update_setting(string @path_to_set_groups, string @path_to_test) {
    console('CHUnit: updating '.@path_to_set_groups.'...')
    if (!file_exists(@path_to_set_groups)) {
        console('CHUnit: [ERROR] file '.@path_to_set_groups.' of setting doesn\'t exist')
        console('CHUnit: Sure that path is correct.')
        return()
    }
    @prop = _util_properties_init_self()
    _util_properties_parse_string(@prop, read(@path_to_set_groups))
    @len_pref = length(get_absolute_path(@path_to_test)) - length(@path_to_test)
    @files = array_sort(_util_get_all_scripts(get_absolute_path(@path_to_test)), 'STRING')
    for (@i = 0, @i < array_size(@files), @i++) {
        @file = replace(replace(@files[@i][cslice(@len_pref, -1)], '\\', '.'), '.ms', '')
        if (!_util_properties_contains(@prop, @file), _util_properties_push(@prop, @file, ""))
    }
    write_file(@path_to_set_groups, _util_properties_to_string(@prop), 'OVERWRITE')
    console('CHUnit: '.@path_to_set_groups.' updated')
}

proc _package_unit_start_test(@path_to_set_groups, @setting, @groups) {
    console('CHUnit: starting tests...')
    @prop = _util_properties_init_self()
    if (array_size(@arguments) < 4) {
        console('CHUnit: [ERROR] no out?')
        console('CHUnit: finish')
        return()
    }
    if (!file_exists(@path_to_set_groups)) {
        console('CHUnit: [ERROR] properties group don\'t found')
        console('CHUnit: finish')
        return()
    }
    _util_properties_parse_string(@prop, read(@path_to_set_groups))
    @tests = array()

    if (array_contains(@groups, 'all')) {
        @tests = _util_properties_key_set(@prop)
    } else {

        foreach(@file: @group in _util_properties_to_map(@prop)) {
            if (array_contains(@groups, @group)) {
                array_push(@tests, @file)
            }
        }

    }
    @out = array()
    for(@i = 4, @i < array_size(@arguments), @i++) {
        array_push(@out, @arguments[@i])
    }

    _package_unit_do_tests(@tests, @setting, @out)
}
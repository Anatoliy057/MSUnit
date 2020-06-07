proc _package_unit_create_setting(string @path_to_groups, string @path_to_test, string @def_value, string @group_del) {
    console('MSUnit: creating '.@path_to_groups.' ...', false)
    _util_make_dir(@path_to_groups)
    @files = array_sort(_util_get_all_scripts(@path_to_test), 'STRING')
    @prop = _util_properties_init_self()
    foreach(@file in @files) {
        @file = replace(@file[cslice(length(@path_to_test) + 1, -1)], '.ms', '')
        @file_group = @file
        @file = replace(@file, '\\', '.')
        _util_properties_push(
            @prop,
            @file,
            @def_value.@group_del.@file_group
        )
    }
    if (!file_exists(@path_to_groups), create_file(@path_to_groups))
    write_file(@path_to_groups, _util_properties_to_string(@prop), 'OVERWRITE')
    console('MSUnit: '.@path_to_groups.' created', false)
}

proc _package_unit_update_setting(string @path_to_groups, string @path_to_test, string @def_value, string @group_del) {
    console('MSUnit: updating '.@path_to_groups.'...', false)
    if (!file_exists(@path_to_groups)) {
        console(_package_unit_msg_module_log('setting_groups_not_found', @path_to_groups), false)
    }
    @prop = _util_properties_init_self()
    _util_properties_parse_string(@prop, read(@path_to_groups))
    @files = array_sort(_util_get_all_scripts(@path_to_test), 'STRING')
    for (@i = 0, @i < array_size(@files), @i++) {
        @file = @files[@i]
        @file = replace(@file[cslice(length(@path_to_test) + 1, -1)], '.ms', '')
        @file_group = @file
        @file = replace(@file, '\\', '.')
        if (!_util_properties_contains(@prop, @file), _util_properties_push(@prop, @file, @def_value.@group_del.@file_group))
    }
    write_file(@path_to_groups, _util_properties_to_string(@prop), 'OVERWRITE')
    console('MSUnit: '.@path_to_groups.' updated', false)
}

proc _package_unit_run_test(@path_to_test, @path_to_groups, @setting, @groups, @del_groups, @out) {
    console('MSUnit: recompiling tests...', false)
    x_recompile_includes(@path_to_test)
    console('MSUnit: finished recompile...', false)
    console('MSUnit: starting tests...', false)
    @prop = _util_properties_init_self()
    if (!file_exists(@path_to_groups)) {
        console(_package_unit_msg_module_log('setting_groups_not_found', @path_to_groups), false)
    }
    _util_properties_parse_string(@prop, read(@path_to_groups))
    @tests = array()

    foreach(@file: @str_group in _util_properties_to_map(@prop)) {
        if (_util_array_some_contains(split(@del_groups, @str_group), @groups)) {
            array_push(@tests, @file)
        }
    }
    _package_unit_runner(@tests, @path_to_test, @setting, @out)
}

proc _package_unit_start_test(@path_to_groups, @setting, @groups, @del_groups, @out) {
    console('MSUnit: starting tests...', false)
    @prop = _util_properties_init_self()
    if (!file_exists(@path_to_groups)) {
        console(_package_unit_msg_module_log('setting_groups_not_found', @path_to_groups), false)
    }
    _util_properties_parse_string(@prop, read(@path_to_groups))
    @tests = array()

    foreach(@file: @str_group in _util_properties_to_map(@prop)) {
        if (_util_array_some_contains(split(@del_groups, @str_group), @groups)) {
            array_push(@tests, @file)
        }
    }

    _package_unit_runner(@tests, @setting, @out)
}
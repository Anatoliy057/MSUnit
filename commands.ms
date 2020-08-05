proc _package_unit_commands_get() {
    return(import('org.cadabra.msunit.commands'))
}

proc _package_unit_create_setting(string @path_to_groups, string @filter, string @path_to_test, string @def_value, string @group_del) {
    console('MSUnit: creating '.@path_to_groups.' ...', false)
    _util_make_file(@path_to_groups)
    @files = array_sort(_util_get_all_scripts(@path_to_test, @filter), 'STRING')
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

proc _package_unit_update_setting(string @path_to_groups, string @filter, string @path_to_test, string @def_value, string @group_del) {
    console('MSUnit: updating '.@path_to_groups.'...', false)
    if (!file_exists(@path_to_groups)) {
        console(_package_unit_msg_module_log('setting_groups_not_found', @path_to_groups), false)
    }
    @prop = _util_properties_init_self()
    _util_properties_parse_string(@prop, read(@path_to_groups))
    @files = array_sort(_util_get_all_scripts(@path_to_test, @filter), 'STRING')
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

proc _package_unit_run_test(@module, @setting, @groups) {
    console('MSUnit: recompiling tests...', false)
    x_recompile_includes(@module['tests'])
    console('MSUnit: recompiling local packages...', false)
    x_recompile_includes(@module['localPackages'])
    console('MSUnit: finished recompile...', false)
    console('MSUnit: starting tests...', false)
    @prop = _util_properties_init_self()
    if (!file_exists(@module['setting_tests'])) {
        console(_package_unit_msg_module_log('setting_groups_not_found', @module['setting_tests']), false)
    }
    _util_properties_parse_string(@prop, read(@module['setting_tests']))
    @tests = array()
    foreach(@file: @str_group in _util_properties_to_map(@prop)) {
        if (_util_array_some_contains(split(@setting['props']['delimiter'], @str_group), @groups)) {
            @tests[] = @file
        }
    }
    x_new_thread('(MSUNIT) Tester thread', closure() {    
        _package_unit_tester(@tests, @module, @setting['tests'], @module['out'])
    })
}

proc _package_unit_start_test(@module, @setting, @groups) {
    console('MSUnit: starting tests...', false)
    @prop = _util_properties_init_self()
    if (!file_exists(@module['setting_tests'])) {
        console(_package_unit_msg_module_log('setting_groups_not_found', @module['setting_tests']), false)
    }
    _util_properties_parse_string(@prop, read(@module['setting_tests']))
    @tests = array()
    foreach(@file: @str_group in _util_properties_to_map(@prop)) {
        if (_util_array_some_contains(split(@setting['props']['delimiter'], @str_group), @groups)) {
            @tests[] = @file
        }
    }
    x_new_thread('(MSUNIT) Tester thread', closure() {
        _package_unit_tester(@tests, @module, @setting['tests'], @module['out'])
    })
}


proc _package_unit_commands_init(@setting) {
    @global_setting = import('org.cadabra.msunit.setting')

    @commander = _util_commander_init_self()

    @global_setting['tests']['name_module'] = @setting['id']

    _util_commander_register(
        @commander,
        @global_setting['commands']['init'],
        closure() {
            if (array_size(@arguments[0]) > 0) {
                _package_unit_create_setting(@setting['setting_tests'], @setting['filter'], @setting['tests'], array_implode(@arguments[0], @global_setting['props']['delimiter']), @global_setting['props']['delimiter'])
            } else {
                _package_unit_create_setting(@setting['setting_tests'], @setting['filter'], @setting['tests'], @global_setting['props']['defualt_group'], @global_setting['props']['delimiter'])
            }
        }
    )

    _util_commander_register(
        @commander,
        @global_setting['commands']['update'],
        closure() {
            if (array_size(@arguments[0]) > 0) {
                _package_unit_update_setting(@setting['setting_tests'], @setting['filter'], @setting['tests'], array_implode(@arguments[0], @global_setting['props']['delimiter']), @global_setting['props']['delimiter'])
            } else {
                _package_unit_update_setting(@setting['setting_tests'], @setting['filter'], @setting['tests'], @global_setting['props']['defualt_group'], @global_setting['props']['delimiter'])
            }
        }
    )

    _util_commander_register(
        @commander,
        @global_setting['commands']['start'],
        closure() {
            _package_unit_start_test(@setting, @global_setting, @arguments[0])
        }
    )

    _util_commander_register(
        @commander,
        @global_setting['commands']['run'],
        closure() {
            _package_unit_run_test(@setting, @global_setting, @arguments[0])
        }
    )

    export('org.cadabra.msunit.commands', @commander)
}
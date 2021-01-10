proc _unit_register_module(array @settings) {

    array @module_settings = _msunit_load_resource('setting.yml')

    string @root
    string @id

    if (_key_in(@settings, 'id')) {
        @module_settings['id'] = @settings['id']
        @id = @settings['id']
    } else {
        throw(NotFoundException, 'You must specify the "id"')
    }

    if (_key_in(@settings, 'root')) {
        @module_settings['root'] = @settings['root']
        @root = @settings['root']
    } else {
        throw(NotFoundException, 'You must specify the "root"')
    }

    if (_key_in(@settings, 'root_tests')) {
        @module_settings['root_tests'] = @settings['root_tests']
    } else {
        @module_settings['root_tests'] = "@root/tests"
    }

    if (_key_in(@settings, 'root_resources')) {
        @module_settings['root_resources'] = @settings['root_resources']
    } else {
        @module_settings['root_resources'] = "@root/resources"
    }

    if (_key_in(@settings, 'ignore_match')) {
        @module_settings['ignore_match'] = @settings['ignore_match']
    } else {
        @module_settings['ignore_match'] = null
    }

    if (_key_in(@settings, 'test_groups')) {
        @module_settings['test_groups'] = @root.'/'.@settings['test_groups']
    } else {
        @module_settings['test_groups'] = "@root/settings.prop"
    }

    if (_key_in(@settings, 'outs')) {
        @outs = array()
        foreach(@out in @settings['outs']) {
            @outs[] = _msunit_new_out(@out)
        }
        @module_settings['outs'] = @outs
    } else {
        @module_settings['outs'] = _msunit_get_outs("@root/logs")
    }

    if (!is_dir(@root)) {
        throw(IllegalArgumentException, 'Specify "root" is not directory')
    }

    _util_replace_in_array(@module_settings, @settings)

    _msunit_import_runners()[@id] = closure() {
        _msunit_run(@agruments, @module_setting)
    }
}

array proc _msunit_get_outs(string @path_to_log, string @root, array @filters = array()) {
    return(
        array(
            _msunit_new_out(
                closure(@text) {
                    console(colorize(@text), false)
                }
            ),
            _msunit_new_out(
                closure(@text) {
                    @path_to_log_file = "@path_to_log/".simple_date('yyyy.MM.dd').'.log'
                    if (!file_exists(@path_to_log_file)) {
                        _util_make_file(@path_to_log_file, @root)
                    }
                    write_file(@path_to_log_file, strip_colors(@text), 'APPEND')
                }
            )
        )
    )
}

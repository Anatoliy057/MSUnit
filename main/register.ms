array proc _msunit_import_runners() {
    return(import('org.cadabra.msunit.modules'))
}

proc _unit_register_module(array @settings) {

    array @module_settings = _msunit_load_resource('setting.yml')

    string @root
    string @id

    if (array_index_exists(@settings, 'id')) {
        @module_settings['id'] = @settings['id']
        @id = @settings['id']
    } else {
        throw(NotFoundException, 'You must specify the "id"')
    }

    if (array_index_exists(@settings, 'root')) {
        @module_settings['root'] = @settings['root']
        @root = @settings['root']
    } else {
        throw(NotFoundException, 'You must specify the "root"')
    }

    if (array_index_exists(@settings, 'root_tests')) {
        @module_settings['root_tests'] = @settings['root_tests']
    } else {
        @module_settings['root_tests'] = "@root/tests"
    }

    if (array_index_exists(@settings, 'root_resources')) {
        @module_settings['root_resources'] = @settings['root_resources']
    } else {
        @module_settings['root_resources'] = "@root/resources"
    }

    if (array_index_exists(@settings, 'ignore_match')) {
        @module_settings['ignore_match'] = @settings['ignore_match']
    } else {
        @module_settings['ignore_match'] = null
    }

    if (array_index_exists(@settings, 'test_settings')) {
        @module_settings['test_settings'] = @settings['test_settings']
    } else {
        @module_settings['test_settings'] = "@root/settings.prop"
    }

    if (array_index_exists(@settings, 'outs')) {
        @module_settings['outs'] = @settings['outs']
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

array proc _msunit_get_outs(string @path_to_log, string @root, array @filters = array('message', 'test_log', 'user_log')) {
    return(
        array(
            array(
                'filters' : @filters,
                'write' : closure(@text) {
                    console(colorize(@text), false)
                }
            ),
            array(
                'filters' : @filters,
                'write' : closure(@text) {
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

export('org.cadabra.msunit.modules', associative_array())
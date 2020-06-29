array proc _package_unit_get_constants() {
    return(import('org.cadabra.msunit.register'))
}

export('org.cadabra.msunit.register', array(modules: array()))

proc _unit_register_module_fast(string @id, string @folder) {
    if (!is_dir(@folder)) {
        console(
            "[FATAL] This is not a directory: @folder\n"
            ."In _unit_register_module_fast()",
            , false
        )
        die()
    }
    @conts = _package_unit_get_constants()
    @path_to_log = @folder.'\\logs'
    @conts['modules'][@id] = array(
        id: @id,
        setting_tests: @folder.'\\tests.properties',
        tests: @folder,
        outs: _unit_get_default_outs(@path_to_log)
    )
}

proc _unit_register_module(string @id, string @folder, string @groups, array @outs) {
    if (!is_dir(@folder)) {
        console(
            "[FATAL] This is not a directory: @folder\n"
            ."In _unit_register_module()",
            , false
        )
        die()
    }
    @conts = _package_unit_get_constants()
    @conts['modules'][@id] = array(
        id: @id,
        setting_tests: @groups,
        tests: @folder,
        outs: @outs
    )
}

array proc _unit_get_default_outs(string @path_to_log, int @ignore_for_permission = 3) {
    return(
        array(
            array(
                'enable' : true,
                'short' : false,
                'write' : closure(@text) {
                    console(@text, false)
                }
            ),
            array(
                'enable' : true,
                'short' : false,
                'write' : closure(@text) {
                    @path_to_log_file = @path_to_log.'\\'.simple_date('yyyy.MM.dd').'.txt'
                    if (!file_exists(@path_to_log_file)) {
                        _util_make_file(@path_to_log_file, '\\', @ignore_for_permission)
                    }
                    write_file(@path_to_log_file, @text, 'APPEND')
                }
            )
        )
    )
}
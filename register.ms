array proc _package_unit_get_constants() {
    return(import('org.cadabra.msunit.register'))
}

export('org.cadabra.msunit.register', array(modules: array()))

proc _unit_register_module(array @args) {

    string @id = @args['id']
    string @folder = @args['folder']
    if (!is_dir(@folder)) {
        console(
            "[FATAL] This is not a directory: @folder"
            ." In _unit_register_module()",
            , false
        )
        die()
    }
    string @groups =if (array_index_exists(@args, 'groups'), @args['groups'], @folder.'\\tests.properties')
    string @filter = if(array_index_exists(@args, 'filter'), @args['filter'], null)
    array @outs = if(array_index_exists(@args, 'outs'), @args['outs'], @args['outs'] = _unit_get_default_outs(@folder.'\\logs'))

    @conts = _package_unit_get_constants()
    @conts['modules'][@id] = array(
        id: @id,
        setting_tests: @groups,
        tests: @folder,
        filter: @filter,
        outs: @outs,
        run: closure(string @arg, array @setting) {
            include('statics.ms')
            include('resourse.ms')
            include('message.ms')
            include('log_builder.ms')
            include('commands.ms')
            include('tester.ms')
            include('assertion_api.ms')
            include('runner.ms')
            _unit_run(@arg, @setting)
        }
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
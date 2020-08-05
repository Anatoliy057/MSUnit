array proc _package_unit_get_constants() {
    return(import('org.cadabra.msunit.register'))
}

export('org.cadabra.msunit.register', array(modules: array()))

proc _unit_register_module(array @args) {

    string @id = @args['id']
    string @root = @args['root']
    if (!is_dir(@root)) {
        console(
            "[FATAL] This is not a directory: @root"
            ." In _unit_register_module()",
            , false
        )
        die()
    }
    string @tests = if(array_index_exists(@args, 'tests'), @root.'\\'.@args['tests'], @root.'\\tests')
    string @groups = if(array_index_exists(@args, 'groups'), @root.'\\'.@args['groups'], @root.'\\tests.properties')
    string @filter = if(array_index_exists(@args, 'filter'), @args['filter'], null)
    array @outs = if(array_index_exists(@args, 'outs'), @args['outs'], @args['outs'] = _unit_get_default_outs(@root.'\\logs'))
    string @resource = if(array_index_exists(@args, 'resource'), @root.'\\'.@args['resource'], @root.'\\resource')
    string @localPackages = if (array_index_exists(@args, 'localPackages'), @root.'\\'.@args['localPackages'].'\\main.ms', @root.'\\localPackages\\main.ms')

    @conts = _package_unit_get_constants()
    @conts['modules'][@id] = array(
        id: @id,
        setting_tests: @groups,
        tests: @tests,
        filter: @filter,
        out: @outs,
        resource: @resource,
        localPackages: @localPackages,
        run: closure(string @arg, array @setting) {
            include('statics.ms')
            include('resourse.ms')
            include('message.ms')
            include('log_builder.ms')
            include('commands.ms')
            include('tester.ms')
            include('assertion_api.ms')
            include('runner.ms')
            include('resource_api.ms')
            _unit_run(@arg, @setting)
        }
    )
}

array proc _unit_get_default_outs(string @path_to_log, array @filters = array('message', 'test_log', 'user_log'), int @ignore_for_permission = 3) {
    return(
        array(
            array(
                'filters' : @filters,
                'write' : closure(@text) {
                    console(@text, false)
                }
            ),
            array(
                'filters' : @filters,
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
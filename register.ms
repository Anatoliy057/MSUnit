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
    string @tests = if(array_index_exists(@args, 'tests'), @root._util_sdn().@args['tests'], @root._util_sdn().'tests')
    string @groups = if(array_index_exists(@args, 'groups'), @root._util_sdn().@args['groups'], @root._util_sdn().'tests.properties')
    string @filter = if(array_index_exists(@args, 'filter'), @args['filter'], null)
    array @outs = if(array_index_exists(@args, 'outs'), @args['outs'], @args['outs'] = _unit_get_default_outs(@root._util_sdn().'logs'))
    string @resources = if(array_index_exists(@args, 'resources'), @root._util_sdn().@args['resources'], @root._util_sdn().'resources')
    string @util = if (array_index_exists(@args, 'util'), @root._util_sdn().@args['util']._util_sdn().'main.ms', @root._util_sdn().'util'._util_sdn().'main.ms')
    int @ignore = if (array_index_exists(@args, 'ignore'), @args['ignore'], array_size(split(_util_sdn(), @root)) - 1)
    _util_make_file(@util, @ignore)
    _util_make_folder(@tests, @ignore)
    _util_make_folder(@resources, @ignore)
    _util_make_file(@groups, @ignore)

    @conts = _package_unit_get_constants()
    @conts['modules'][@id] = array(
        id: @id,
        setting_tests: @groups,
        tests: @tests,
        filter: @filter,
        out: @outs,
        resources: @resources,
        util: @util,
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

array proc _unit_get_default_outs(string @path_to_log, array @filters = array('message', 'test_log', 'user_log')) {
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
                    @path_to_log_file = @path_to_log._util_sdn().simple_date('yyyy.MM.dd').'.log'
                    if (!file_exists(@path_to_log_file)) {
                        _util_make_file(@path_to_log_file, -3)
                    }
                    write_file(@path_to_log_file, strip_colors(@text), 'APPEND')
                }
            )
        )
    )
}
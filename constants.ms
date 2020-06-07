@UNIT_PATH_MSG = 'message.json'

@UNIT_COMMAND_PREFIX = '-'
@UNIT_COMMAND_INIT = 'init'
@UNIT_COMMAND_RUN = 'run'
@UNIT_COMMAND_UPDATE = 'update'

@UNIT_COMMAND_START = 'start'

@UNIT_GROUP_DEL = '|'
@UNIT_DEFAULT_GROUP = 'all'

@UNIT_DEFAULT_COMMAND = '-update all -run all'

@UNIT_SETTING = array(
    'assert_timeout' : 5,
    'proc_timeout' : 10,
    'number_threads' : 4,
    'pref_test_proc' : '_unit_test_',
    'pref_before_proc' : '_unit_before_each_',
    'pref_test_init_proc' : '_unit_before_all_'    
)

string proc _package_unit_constants_name() {
    return('__UNIT_SETTING')
}

array proc _package_unit_get_constants() {
    return(import(_package_unit_constants_name()))
}

export(_package_unit_constants_name(), array(modules: array()))

proc _unit_register_module_fast(string @id, string @folder) {
    @conts = _package_unit_get_constants()
    @path_to_log = @folder.'\\logs'
    @conts['modules'][@id] = array(
        id: @id,
        setting_tests: @folder.'\\tests.properties',
        tests: @folder,
        outs: _unit_get_default_outs(@path_to_log)
    )
}

proc _unit_register_module_pro(string @id, string @folder, string @groups, array @outs) {
    @conts = _package_unit_get_constants()
    @conts['modules'][@id] = array(
        id: @id,
        setting_tests: @groups,
        tests: @folder,
        outs: @outs
    )
}

proc _unit_get_default_outs(@path_to_log) {
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
                    if (file_exists(@path_to_log_file)) {
                        _util_make_dir(@path_to_log_file)
                    }
                    write_file(@path_to_log_file, @text, 'APPEND')
                }
            )
        )
    )
}

_unit_register_module_pro('unit', get_absolute_path('test'), get_absolute_path('tests.properties'), _unit_get_default_outs(get_absolute_path('logs')))
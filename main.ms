if (!import('unit_run')) {
    include('constants.ms')
    register_command('unit', array(
  	    'description': 'Unit module control',
  	    'usage': '/unit',
  	    'aliases':array('unit', 'test'),
  	    'executor': closure() {
            @size = array_size(@arguments[2])
            if (@size == 0) {
                export('unit_arg', '-start all')
            } else {
                @builder = res_create_resource('STRING_BUILDER')
                for(@i = 0, @i < @size, @i++) {
                    string_append(@builder, @arguments[2][@i])
                }
                export('unit_arg', string(@builder))
            }
            export('unit_run', true)
            include('main.ms')
  	    }
    ));
    if (import('module_log')) {
        console('CHUnit ready to start')
    }
    if (!file_exists(@UNIT_PATH_SETTING)) {
        console('CHUnit: [WARNING] file '.@UNIT_PATH_SETTING.' of setting doesn\'t exist')
        console('CHUnit: Sure that path is correct.')
    }
} else {

include('commands.ms')
include('runner.ms')

@__unit_start_main = closure(string @arg) {
    @args = _util_split_arg(@arg, @UNIT_COMMAND_PREFIX)

    @commander = _util_commander_init_self()

    _util_commander_register(
        @commander,
        @UNIT_COMMAND_INIT,
        closure() {
            _package_unit_create_setting(@UNIT_PATH_SETTING, @UNIT_PATH_TEST)
        }
    )

    _util_commander_register(
        @commander,
        @UNIT_COMMAND_UPDATE,
        closure() {
            _package_unit_update_setting(@UNIT_PATH_SETTING, @UNIT_PATH_TEST)
        }

    )

    _util_commander_register(
        @commander,
        @UNIT_COMMAND_START,
        closure() {
            _package_unit_start_test(@UNIT_PATH_SETTING, @UNIT_SETTING, @arguments[0], @UNIT_CONSOLE_OUT, @UNIT_FILE_OUT)
        }
    )

    @size = array_size(@args)
    for(@i = 0, @i < @size, @i++) {
        _util_commander_execute(@commander, @args[@i][0], @args[@i][1])
    }
}

execute(import('unit_arg'), @__unit_start_main)
}
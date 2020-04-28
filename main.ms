if (!import('unit_run')) {
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
} else {

include('constants.ms')
include('commands.ms')

@__unit_start_main = closure(string @arg) {
    @args = _unit_split_arg(@arg, @UNIT_DEFAULT_COMMAND_PREFIX)

    @commander = _util_commander_init_self()

    _util_commander_register(
        @commander,
        @UNIT_DEFAULT_COMMAND_INIT,
        closure() {
            _package_unit_create_setting(@UNIT_DEFAULT_PATH_SETTING, @UNIT_DEFAULT_PATH_TEST)
        }
    )

    _util_commander_register(
        @commander,
        @UNIT_DEFAULT_COMMAND_UPDATE,
        closure() {
            _package_unit_update_setting(@UNIT_DEFAULT_PATH_SETTING, @UNIT_DEFAULT_PATH_TEST)
        }

    )
    _util_commander_register(
        @commander,
        @UNIT_DEFAULT_COMMAND_START,
        closure() {
            _package_unit_start_test(@UNIT_DEFAULT_PATH_SETTING, @UNIT_DEFAULT_PATH_TEST)
        }
    )

    @size = array_size(@args)
    for(@i = 0, @i < @size, @i++) {
        _util_commander_execute(@commander, @args[@i][0], @args[@i][1])
    }
}

execute(import('unit_arg'), @__unit_start_main)
}
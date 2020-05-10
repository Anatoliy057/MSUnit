if (!import('__unit_run')) {
    include('constants.ms')
    register_command('unit', array(
  	    'description': 'Unit module control',
  	    'usage': '/unit',
  	    'aliases':array('unit', 'test'),
  	    'executor': closure() {
            if (array_size(@arguments[2]) == 0) {
                export('__unit_arg', @UNIT_DEFAULT_COMMAND)
            } else {
                export('__unit_arg', array_implode(@arguments[2], ' '))
            }
            export('__unit_run', true)
            include('main.ms')
  	    }
    ));
    if (import('module_log')) {
        console('MSUnit ready to start', false)
    }
    if (!file_exists(@UNIT_PATH_SETTING)) {
        console(_package_unit_get_msg('setting_groups_not_found', @UNIT_PATH_SETTING), false)
    }
} else {

include('statics.ms')
include('resourse.ms')
include('environment.ms')
include('message.ms')
include('synchron.ms')
include('log_builder.ms')
include('commands.ms')
include('runner.ms')
include('assertion_api.ms')

@__unit_start_main = closure(string @arg) {
    @args = _util_split_arg(@arg, @UNIT_COMMAND_PREFIX)

    @commander = _util_commander_init_self()

    _util_commander_register(
        @commander,
        @UNIT_COMMAND_INIT,
        closure() {
            if (array_size(@arguments[0]) > 0) {
                _package_unit_create_setting(@UNIT_PATH_SETTING, @UNIT_PATH_TEST, array_implode(@arguments[0], @UNIT_GROUP_DEL), @UNIT_GROUP_DEL)
            } else {
                _package_unit_create_setting(@UNIT_PATH_SETTING, @UNIT_PATH_TEST, @UNIT_DEFAULT_GROUP, @UNIT_GROUP_DEL)
            }
        }
    )

    _util_commander_register(
        @commander,
        @UNIT_COMMAND_UPDATE,
        closure() {
            if (array_size(@arguments[0]) > 0) {
                _package_unit_update_setting(@UNIT_PATH_SETTING, @UNIT_PATH_TEST, array_implode(@arguments[0], @UNIT_GROUP_DEL), @UNIT_GROUP_DEL)
            } else {
                _package_unit_update_setting(@UNIT_PATH_SETTING, @UNIT_PATH_TEST, @UNIT_DEFAULT_GROUP, @UNIT_GROUP_DEL)
            }
        }
    )

    _util_commander_register(
        @commander,
        @UNIT_COMMAND_START,
        closure() {
            _package_unit_start_test(@UNIT_PATH_SETTING, @UNIT_SETTING, @arguments[0], @UNIT_GROUP_DEL, @UNIT_CONSOLE_OUT, @UNIT_FILE_OUT)
        }
    )

    _util_commander_register(
        @commander,
        @UNIT_COMMAND_RECOMPILE,
        closure() {
            _package_unit_recompile()
        }
    )

    @size = array_size(@args)
    for(@i = 0, @i < @size, @i++) {
        _util_commander_execute(@commander, @args[@i][0], @args[@i][1])
    }
}

execute(import('__unit_arg'), @__unit_start_main)

}
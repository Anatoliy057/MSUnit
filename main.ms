if (!import('__unit_run')) {
    include('constants.ms')

    register_command('unit', array(
  	    'description': 'Unit module control',
  	    'usage': '/unit',
  	    'aliases':array('unit', 'test'),
  	    'executor': closure() {
            if (array_size(@arguments[2]) == 0) {
                export('__unit_arg', array(arg: @UNIT_DEFAULT_COMMAND, setting: _package_unit_get_constants()['modules']['unit']))
            } else if (array_size(@arguments[2]) == 1) {
                if (!array_index_exists(_package_unit_get_constants()['modules'], @arguments[2][0])) {
                    console('MSUnit: [FATAL] Unkown module')
                    die()
                }
                export('__unit_arg', array(arg: @UNIT_DEFAULT_COMMAND, setting: _package_unit_get_constants()['modules'][@arguments[2][0]]))
            } else {
                export('__unit_arg', array(arg: array_implode(@arguments[2][1..], ' '), setting: _package_unit_get_constants()['modules'][@arguments[2][0]]))
            }
            export('__unit_run', true)
            include('main.ms')
  	    }
    ));
    if (import('module_log')) {
        console('MSUnit ready to start', false)
    }
} else {
execute(closure() {

include('statics.ms')
include('resourse.ms')
include('environment.ms')
include('message.ms')
include('synchron.ms')
include('log_builder.ms')
include('commands.ms')
include('runner.ms')
include('assertion_api.ms')

@setting = import('__unit_arg')['setting']
@UNIT_SETTING['name_module'] = @setting['id']
@__unit_start_main = closure(string @arg) {
    @args = _util_split_arg(@arg, @UNIT_COMMAND_PREFIX)

    @commander = _util_commander_init_self()

    _util_commander_register(
        @commander,
        @UNIT_COMMAND_INIT,
        closure() {
            if (array_size(@arguments[0][0]) > 0) {
                _package_unit_create_setting(@setting['setting_tests'], @setting['tests'], array_implode(@arguments[0][0], @UNIT_GROUP_DEL), @UNIT_GROUP_DEL)
            } else {
                _package_unit_create_setting(@setting['setting_tests'], @setting['tests'], @UNIT_DEFAULT_GROUP, @UNIT_GROUP_DEL)
            }
        }
    )

    _util_commander_register(
        @commander,
        @UNIT_COMMAND_UPDATE,
        closure() {
            if (array_size(@arguments[0][0]) > 0) {
                _package_unit_update_setting(@setting['setting_tests'], @setting['tests'], array_implode(@arguments[0][0], @UNIT_GROUP_DEL), @UNIT_GROUP_DEL)
            } else {
                _package_unit_update_setting(@setting['setting_tests'], @setting['tests'], @UNIT_DEFAULT_GROUP, @UNIT_GROUP_DEL)
            }
        }
    )

    _util_commander_register(
        @commander,
        @UNIT_COMMAND_START,
        closure() {
            _package_unit_start_test(@setting['setting_tests'], @UNIT_SETTING, @arguments[0][0], @UNIT_GROUP_DEL, @setting['outs'])
        }
    )

    _util_commander_register(
        @commander,
        @UNIT_COMMAND_RUN,
        closure() {
            _package_unit_run_test(@setting['tests'], @setting['setting_tests'], @UNIT_SETTING, @arguments[0][0], @UNIT_GROUP_DEL, @setting['outs'])
        }
    )

    @size = array_size(@args)
    for(@i = 0, @i < @size, @i++) {
        _util_commander_execute(@commander, @args[@i][0], @args[@i][1])
    }
}

execute(import('__unit_arg')['arg'], @__unit_start_main)

})}
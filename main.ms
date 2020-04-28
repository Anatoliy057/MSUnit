include('constants.ms')
include('commands.ms')

export('script_log', false)
export('module_log', false)
include(@UNIT_DEFAULT_PATH_MAIN)
export('script_log', true)
export('module_log', true)

@__unit_start_main = closure(string @arg) {
    @args = _unit_split_arg(@arg, @UNIT_DEFAULT_COMMAND_PREFIX)

    @commander = _util_new_commander_object()
   
    execute(
        @UNIT_DEFAULT_COMMAND_INIT,
        closure() {
            _package_unit_create_setting(@UNIT_DEFAULT_PATH_SETTING, @UNIT_DEFAULT_PATH_TEST)
        },
        @commander['register']
    )
    execute(
         @UNIT_DEFAULT_COMMAND_UPDATE,
         closure() {
             _package_unit_update_setting(@UNIT_DEFAULT_PATH_SETTING, @UNIT_DEFAULT_PATH_TEST)
         },
         @commander['register']
    )
    execute(
        @UNIT_DEFAULT_COMMAND_START,
        closure() {
            _package_unit_start_test(@UNIT_DEFAULT_PATH_SETTING, @UNIT_DEFAULT_PATH_TEST)
        },
        @commander['register']
    )

    @size = array_size(@args)
    for(@i = 0, @i < @size, @i++) {
        execute(@args[@i][0], @args[@i][1], @commander['execute'])
    }
}

execute(import('unit_arg'), @__unit_start_main)
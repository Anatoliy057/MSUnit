@UNIT_DEFAULT_PATH_SETTING = "setting.properties"
@UNIT_DEFAULT_PATH_TEST = "test"

include('commands.ms')

@__util_start_main = closure(string @arg) {
    @args = split(" ", @arg)

    @commander = _util_new_commander()
   
    execute('init',
        closure() {
            _package_unit_create_setting(@UNIT_DEFAULT_PATH_SETTING, @UNIT_DEFAULT_PATH_TEST)
        },
        @commander['register']
    )
}

execute(import('util_arg'))
include('register.ms')
include('statics.ms')
include('resourse.ms')
include('message.ms')
include('log_builder.ms')
include('commands.ms')
include('tester.ms')
include('assertion_api.ms')
include('runner.ms')

proc _unit_init_module() {

    _unit_register_module(
        'msunit',
        get_absolute_path('msunit/tests'),
        get_absolute_path('msunit/tests.properties'),
        _unit_get_default_outs(get_absolute_path('msunit/logs'))
    )

    register_command('unit', array(
    'description': 'Unit module control',
    'usage': '/unit',
    'aliases':array('unit', 'test'),
    'executor': closure() {
            if (array_size(@arguments[2]) == 0) {
                console('MSUnit: [FATAL] no arguments', false)
                die()
            } else if (array_size(@arguments[2]) == 1) {
                if (!array_index_exists(_package_unit_get_constants()['modules'], @arguments[2][0])) {
                    console('MSUnit: [FATAL] Unknown module '. @arguments[2][0], false)
                    die()
                }
                _unit_run('-update all -run all',  _package_unit_get_constants()['modules'][@arguments[2][0]][])
            } else {
                _unit_run(array_implode(@arguments[2][1..], ' '),  _package_unit_get_constants()['modules'][@arguments[2][0]][])
            }
        }
    ))
}
include('register.ms')
export('org.cadabra.msunit.path', get_absolute_path(''))

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
            }
            if (!array_index_exists(_package_unit_get_constants()['modules'], @arguments[2][0])) {
                console('MSUnit: [FATAL] Unknown module '. @arguments[2][0], false)
                die()
            }
            if (array_size(@arguments[2]) == 1) {
                @module = _package_unit_get_constants()['modules'][@arguments[2][0]][]
                execute('-update all -run all', @module, @module['run'])
            } else {
                @module = _package_unit_get_constants()['modules'][@arguments[2][0]][]
                execute(array_implode(@arguments[2][1..], ' '), @module, @module['run'])
            }
        }
    ))
}
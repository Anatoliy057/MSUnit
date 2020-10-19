include('constants.ms')
include('register.ms')

proc _unit_init_module() {

    _unit_register_module(associative_array(
        id: 'msunit',
        root: get_absolute_path('msunit'),
        ignore: array_size(split(_util_sdn(), get_absolute_path('msunit')))
    ))

    register_command('unit', array(
    'description': 'MSUnit module control',
    'usage': '/unit',
    'aliases':array('unit'),
    'executor': closure() {
            x_thread_join('(MSUNIT) Tester thread')
            @args = @arguments
            if (array_size(@args[2]) == 0) {
                console('MSUnit: [FATAL] no arguments', false)
                die()
            }
            if (!array_index_exists(_package_unit_get_constants()['modules'], @args[2][0])) {
                console('MSUnit: [FATAL] Unknown module '. @args[2][0], false)
                die()
            }
            if (array_size(@args[2]) == 1) {
                @module = _package_unit_get_constants()['modules'][@args[2][0]][]
                execute(import('org.cadabra.msunit.setting')['default_commands'], @module, @module['run'])
            } else {
                @module = _package_unit_get_constants()['modules'][@args[2][0]][]
                execute(array_implode(@args[2][1..], ' '), @module, @module['run'])
            }
    }))
}
include('register.ms')

proc _unit_init_module() {

    _unit_register_module(associative_array(
        id: 'msunit',
        folder: get_absolute_path('msunit/tests'),
        groups: get_absolute_path('msunit/tests.properties'),
        outs: _unit_get_default_outs(get_absolute_path('msunit/logs'))
    ))

    register_command('unit', array(
    'description': 'MSUnit module control',
    'usage': '/unit',
    'aliases':array('unit', 'test'),
    'executor': closure() {
        @args = @arguments
        x_new_thread('(MSUNIT) Main thread', closure() {
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
                execute('-update all -run all', @module, @module['run'])
            } else {
                @module = _package_unit_get_constants()['modules'][@args[2][0]][]
                execute(array_implode(@args[2][1..], ' '), @module, @module['run'])
            }
        }
    ))
    })
}
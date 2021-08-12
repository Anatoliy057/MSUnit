if(is_proc('_msunit_')) {

void proc _msunit_set_environment(array @moduleSetting, array @states) {
    export('org.cadabra.msunit.environment', array(
        moduleSetting: @moduleSetting,
        states: @states,
    ))
}

void proc _msunit_clear_environment() {
    export('org.cadabra.msunit.environment', null)
}

array proc _msunit_get_state() {
    @id = _msunit_parse_thread()
    @states = _msunit_get_environment()['states']
    return(@states[@id['trimScript']][@id['test']])
}

array proc _msunit_get_context() {
    @id = _msunit_parse_thread()
    @contexts = _msunit_get_environment()['contexts']
    return(@contexts[@id['trimScript']][@id['test']])
}

array proc _msunit_get_environment() {
    return(import('org.cadabra.msunit.environment'))
}

}
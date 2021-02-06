string proc _msunit_import_root() {
    return(import('org.cadabra.msunit')['ROOT'])
} 

string proc _msunit_import_resourse_root() {
    return(import('org.cadabra.msunit')['ROOT_RESOURSE'])
}

string proc _msunit_import_test_api() {
    return(import('org.cadabra.msunit')['TEST_API'])
}

array proc _msunit_import_modules() {
    return(import('org.cadabra.msunit')['modules'])
}

boolean proc _msunit_is_application_started() {
    return(boolean(import('org.cadabra.msunit.application_start')))
}

void proc _msunit_application_start() {
    export('org.cadabra.msunit.application_start', true)
}

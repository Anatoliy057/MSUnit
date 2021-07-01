string proc _msunit_import_root() {
    return(original_import('org.cadabra.msunit')['ROOT'])
} 

string proc _msunit_import_resourse_root() {
    return(original_import('org.cadabra.msunit')['ROOT_RESOURSE'])
}

string proc _msunit_import_test_api() {
    return(original_import('org.cadabra.msunit')['TEST_API'])
}

string proc _msunit_import_test_unsup_api() {
    return(original_import('org.cadabra.msunit')['UNSUPPORTED_API'])
}

array proc _msunit_import_modules() {
    return(original_import('org.cadabra.msunit')['modules'])
}

boolean proc _msunit_is_application_started() {
    return(original_import('org.cadabra.msunit')['appIsRunning'])
}

void proc _msunit_application_start() {
    original_import('org.cadabra.msunit')['appIsRunning'] = true
}

void proc _msunit_export_options(array @options) {
    original_import('org.cadabra.msunit')['options'] = @options
}

array proc _msunit_import_options() {
    return(original_import('org.cadabra.msunit')['options'])
}

array proc _msunit_import_tests_setting() {
    return(original_import('org.cadabra.msunit')['testsSetting'])
}

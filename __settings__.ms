execute(closure() {
    @ROOT = file_resolve('./src/main/ms')
    @ROOT_RESOURSE = file_resolve('./src/main/resources')
    @TEST_API = file_resolve('./src/main/api/test/main.ms')
    @UNSUPPORTED_API = file_resolve('./src/main/api/test/unsupported_api.ms')

    export('org.cadabra.msunit', associative_array(
        //constants
        ROOT: @ROOT,
        ROOT_RESOURSE: @ROOT_RESOURSE,
        TEST_API: @TEST_API,
        UNSUPPORTED_API: @UNSUPPORTED_API,

        //flags
        appIsRunning: false,
        
        //storages
        modules: array(),
        options: yml_decode(read(file_resolve("@ROOT_RESOURSE/options.yml"))),
        testsSetting: yml_decode(read(file_resolve("@ROOT_RESOURSE/tests_setting.yml"))),
    ))
})

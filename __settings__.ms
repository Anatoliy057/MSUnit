execute(closure() {
    export('org.cadabra.msunit', associative_array(
        //constants
        ROOT: file_resolve('./src/main/ms'),
        ROOT_RESOURSE: file_resolve('./src/main/resources'),
        TEST_API: file_resolve('src/main/ms/org/cadabra/msunit/api/test/api.ms'),
        
        //storages
        modules: array(),
    ))
})

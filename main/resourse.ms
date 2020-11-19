execute(closure() {
    if (!file_exists('message.json')) {
        console("MSUnit: [FATAL] file 'message.json' of msgs doesn't exist.\nSure that path is correct.", false)
        die()
    } else {
        export('org.cadabra.msunit.message', json_decode(read('message.json')))
    }
})

string proc _msunit_read_resource(string @path) {
    @fullpath = file_resolve(import('org.cadabra.msunit.resource_path')."/@path")
    
    return(read(@fullpath))
}

array proc _msunit_load_resources(string @path) {
    @fullpath = file_resolve(import('org.cadabra.msunit.resource_path')."/@path")

    return(yml_decode(read(@fullpath)))
}
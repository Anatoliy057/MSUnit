array proc _msunit_get_resourse_loader() {
    return(_msunit_get_class('ResourseLoader'))
}

_msunit_include_add(closure() {
    array @loader = associative_array()

    @loader['read'] = closure(@m, @self, string @filename) {
        @resourseRoot = _msunit_import_resourse_root()
        
        return(read(file_resolve("@resourseRoot/@filename")))
    }

    @loader['loadYml'] = closure(@m, @self, string @filename) {
        @resourseRoot = _msunit_import_resourse_root()
        
        return(yml_decode(_method('read', @self, "@filename.yml")))
    }

    @loader['loadJson'] = closure(@m, @self, string @filename) {
        @resourseRoot = _msunit_import_resourse_root()

        return(yml_decode(_method('read', @self, "@filename.json")))
    }

    _msunit_register_class('ResourseLoader', @loader)
}) 

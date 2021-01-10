array proc _msunit_get_resourse_loader() {
    return(import(_msunit_get_class('ResourseLoader')))
}

execute(closure() {
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

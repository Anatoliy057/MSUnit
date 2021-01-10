array proc _msunit_new_test(string @script, array @procs, array @closuresProcs) {
    array @object = associative_array()

    foreach(@key: @attr in _msunit_import_class('ScriptTest')) {
        @object[@key] = @attr
    }

    @object['closuresProcs'] = @closuresProcs
    @object['procs'] = @procs
    @object['script'] = @script

    return(@object)
}

_msunit_include_add(closure() {

    array @attributes = associative_array()

    @attributes['defineType'] = closure(@m, @self) {
        if (_is_empty(@procs['beforeEach'])) {
            
        }
    }

    _msunit_register_class('ScriptTest', @attributes)
})

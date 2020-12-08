
array proc _msunit_new_out(closure @writter, array @filters = array()) {
    array @object = associative_array()

    @object['filters'] = @filters
    @object['writter'] = @writter

    foreach(@key: @attr in _msunit_import_class('Out')) {
        @object[@key] = @attr
    }

    return(@object)
}

_msunit_include_add(closure() {
    array @attributes = associative_array()

    @attributes['write'] = closure(@m, @self, string @type, string @text) {
        if (@self['filters'] || array_contains(@self['filters'], @type)) {
            execute(@text, @self['writter'])
        }
    }

    _msunit_register_class('Out', @attributes)
}) 
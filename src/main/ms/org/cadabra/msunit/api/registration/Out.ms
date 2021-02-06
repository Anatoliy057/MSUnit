array proc _msunit_new_out(closure @writter) {
    array @self = associative_array()

    @self['writter'] = @writter

    foreach(@key: @attr in _msunit_get_class('Out')) {
        @self[@key] = @attr
    }

    return(@self)
}

_msunit_include_add(closure() {
    array @attributes = associative_array()

    @attributes['write'] = closure(@m, @self, string @text, string @caller) {
        @writter = @self['writter']
        @writter(@text, @caller)
    }

    _msunit_register_class('Out', @attributes)
})

array proc _msunit_new_logger(array @outs) {
    array @self = associative_array()

    foreach(@key: @attr in _msunit_get_class('Logger')) {
        @self[@key] = @attr
    }

    @self['outs'] = @outs

    return(@self)
}

_msunit_include_add(closure() {
    array @attributes = associative_array()

    @attributes['log'] = closure(@m, @self, string @message, string @caller) {
        foreach(@out in @self['outs']) {
            @out(@message, @caller)
        }
    }

    _msunit_register_class('Logger', @attributes)
})

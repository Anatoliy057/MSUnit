array proc _msunit_new_logger() {
    array @self = associative_array()

    foreach(@key: @attr in _msunit_get_class('Logger')) {
        @self[@key] = @attr
    }

    return(@self)
}

_msunit_include_add(closure() {
    array @attributes = associative_array()

    @attributes['setOuts'] = closure(@m, @self, array @outs) {
        @self['outs'] = @outs
    }

    @attributes['log'] = closure(@m, @self, string @message, string @caller) {
        foreach(@out in @self['outs']) {
            _method('write', @out, @message, @caller)
        }
    }

    _msunit_register_class('Logger', @attributes)
})

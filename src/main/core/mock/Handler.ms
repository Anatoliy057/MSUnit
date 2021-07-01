array proc _msunit_new_handler(array @classTypes, mixed @return) {
    array @self = associative_array()

    foreach(@key: @attr in _msunit_get_class('Handler')) {
        @self[@key] = @attr
    }

    if(array_size(@arguments) == 1) {
        @return
    }

    return(@self)
}

_msunit_include_add(closure() {
    array @attributes = associative_array()

    @attributes['return'] = closure(@m, @self) {
        return(@self['proc'])
    }

    @attributes['isSuitable'] = closure(@m, @self, @args) {
        foreach(@handle in @self['handlers']) {
            if(_method(@handle, 'isSuitable', @agrs)) {
                return(_method(@handle, 'return'))
            }
        }
    }

    _msunit_register_class('Handler', @attributes)
})
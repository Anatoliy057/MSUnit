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

    proc _return(@self) {
        return(@self['proc'])
    }

    proc _isSuitable(@self, @args) {
        foreach(@handle in @self['handlers']) {
            if(_method(@handle, 'isSuitable', @agrs)) {
                return(_method(@handle, 'return'))
            }
        }
    }

    _msunit_register_class('Handler', @attributes, array(
        'return': '_return',
        'isSuitable': '_isSuitable',
    ))
})
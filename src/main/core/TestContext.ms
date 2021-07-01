array proc _msunit_new_test_context() {
    array @self = associative_array()

    foreach(@key: @attr in _msunit_get_class('TestContext')) {
        @self[@key] = @attr
    }

    @self['mocks'] = associative_array()

    return(@self)
}

_msunit_include_add(closure() {
    array @attributes = associative_array()

    @attributes['addMock'] = closure(@m, @self, array @mock) {
        @proc = _method('getProc', @mock)
        @self['mocks'][@proc] = @mock
    }

    @attributes['getMock'] = closure(@m, @self, string @proc) {
        return(@self['mocks'][@proc])
    }

    _msunit_register_class('TestContext', @attributes)
})

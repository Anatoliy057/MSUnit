array proc _msunit_new_mock(string @env, string @procName, array @handlers, array @options) {
    array @self = associative_array()

    foreach(@key: @attr in _msunit_get_class('Mock')) {
        @self[@key] = @attr
    }

    @self['proc'] = @procName
    @self['handlers'] = @handlers
    @self['env'] = @env
    @self['passedArgs'] = array()

    @proxySuffx = '_proxy'
    @mockSuffix = '_mock'
    @proxyName = @procName.@proxySuffx
    @mockName = @procName.@mockSuffix

    @script =
    '
    proc '.@proxyName.'() {
        @procName = '.@procName.'
        @context = _msunit_get_context()
        @mock = _method(\'getMock\', @context, @procName)
        @options = @mock[\'options\']
        @returned = _method(\'handle\', @mock, @arguments)
        if(@returned[\'return\'] != true) {
            return(@returned[\'value\'])
        } else {
           return(call_proc_array('.@mockName.', @arguments)) 
        }
    }

    proc '.@mockName.'() {

    }
    '

    eval(@script)

    x_replace_procedure(@mockName, @procName)
    x_add_procedure(@env, @mockName)
    x_replace_procedure(@env, @procName, @proxyName)

    return(@self)
}

_msunit_include_add(closure() {
    array @attributes = associative_array()

    @attributes['getProc'] = closure(@m, @self) {
        return(@self['proc'])
    }

    @attributes['handle'] = closure(@m, @self, @args) {
        foreach(@handle in @self['handlers']) {
            if(_method(@handle, 'isSuitable', @agrs)) {
                return(_method(@handle, 'return'))
            }
        }
    }

    _msunit_register_class('Mock', @attributes)
})
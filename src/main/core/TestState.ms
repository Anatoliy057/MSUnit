array proc _msunit_new_test_state(string @formatScript, array @testsSetting) {
    array @self = associative_array()

    foreach(@key: @attr in _msunit_get_class('TestState')) {
        @self[@key] = @attr
    }

    @self['ASSERT_TIME'] = @testsSetting['assertTimeout']

    @self['userLog'] = res_create_resource('STRING_BUILDER')
    @self['testMessage'] = null
    @self['assertMessage'] = null
    @self['stackTrace'] = null
    @self['successful'] = true
    @self['skipped'] = false
    @self['time'] = 0

    @self['formatScript'] = @formatScript
    @self['assertTime'] = @testsSetting['assertTimeout']
    @self['testTime'] = @testsSetting['testTimeout']
    @self['attentionTime'] = @testsSetting['attentionTime']

    return(@self)
}

_msunit_include_add(closure() {
    array @attributes = associative_array()

    @attributes['setException'] = closure(@m, @self, array @e) {
        @messageEx = @e['message']
        @typeEx = @e['classType']
        @message = "An unexpected @typeEx was thrown"
        @self['testMessage'] = @message
        @self['assertMessage'] = @messageEx
        @self['stackTrace'] = @e['stackTrace']
        @self['successful'] = false
    }

    @attributes['setAssertTimeout'] = closure(@m, @self) {
        @self['successful'] = false
        @self['testMessage'] = 'Time passed waiting for the call _assert*'
    }

    @attributes['setTestTimeout'] = closure(@m, @self) {
        @self['successful'] = false
        @self['testMessage'] = 'Time passed waiting for finish procedure'
    }

    _msunit_register_class('TestState', @attributes)
})

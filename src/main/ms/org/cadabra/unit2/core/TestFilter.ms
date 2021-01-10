array proc _msunit_new_test_filter(array @moduleSetting) {
    array @object = associative_array()

    foreach(@key: @attr in _msunit_import_class('TestFilter')) {
        @object[@key] = @attr
    }

    @object['moduleSetting'] = @moduleSetting

    return(@object)
}

_msunit_include_add(closure() {

    array @attributes = associative_array()

    @attributes['defaultCompile'] = closure(@m, @self) { 
        @not = @self['moduleSetting']['groups']['not']
        @in = @self['moduleSetting']['groups']['in']

        @filter = _method('getFilterObject', @self)

        @filter['$default'] = associative_array()
        @filter['$default']['$all'] = true
    }

    @attributes['compile'] = closure(@m, @self, array @userArgs) {
        if (_is_empty(@userArgs)) {
            _method('defaultCompile', @self)
            return()
        }

        @not = @self['moduleSetting']['groups']['not']
        @in = @self['moduleSetting']['groups']['in']

        @filter = associative_array()
        foreach(@userGroup in @userArgs) {
            @inclusion = !string_contains(@userGroup, '^')
            @userGroup = reg_replace("[@not@in]", '', @userGroup)

            @test = '$default'
            @proc = '$all'
            @filter = associative_array()

            if (@userGroup[0] == ':') {
                @proc = @userGroup

            } else if (!string_contains(@userGroup, ':')) {
                @test = @userGroup

            } else {
                @splitedUserGroup = split(':', @userGroup)
                @test = @splitedUserGroup[0]
                @proc = @splitedUserGroup[1]
            }

            if(!_key_in(@filter, @test)) {
                @filter[@test] = associative_array()
            }

            @filter[@test][@proc] = @inclusion

            @self['filterObject'] = @filter
        }
    }

    @attributes['isTestProc'] = closure(@m, @self, string @test, string @proc) {
        @filter = @self['filterObject']

        if (!_key_in(@filter, @test)) {
            @test = '$default'
        }

        if (!_key_in(@filter[@test], @proc)) {
            @proc = '$all'
        }

        return(@filter[@test][@proc])
    }

    _msunit_register_class('TestFilter', @attributes)
})

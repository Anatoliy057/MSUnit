array proc _msunit_new_test_filter(array @options) {
    array @self = associative_array()

    foreach(@key: @attr in _msunit_get_class('TestFilter')) {
        @self[@key] = @attr
    }

    @self['options'] = @options

    return(@self)
}

_msunit_include_add(closure() {
    array @attributes = associative_array()

    @attributes['defaultTrueCompile'] = closure(@m, @self) { 
        @filter = associative_array()

        @filter['$default']['$all'] = true

        return(@filter)
    }

    @attributes['defaultFalseCompile'] = closure(@m, @self) { 
        @filter = associative_array()

        @filter['$default']['$all'] = false

        return(@filter)
    }

    @attributes['compile'] = closure(@m, @self, array @userArgs) {
        array @filter
        if (_is_empty(@userArgs)) {
            @filter = _method('defaultTrueCompile', @self)
        
        } else {
            @filter = _method('defaultFalseCompile', @self)
        }

        //@filter = _method('defaultTrueCompile', @self)

        @not = @self['options']['groups']['not']

        foreach(@userGroup in @userArgs) {
            @inclusion = !string_contains(@userGroup, @not)
            @userGroup = reg_replace('['.@not.']', '', @userGroup)

            @group = '$default'
            @test = '$all'

            if (@userGroup[0] == ':') {
                @test = @userGroup[1..]
                @filter['$default']['$all'] = !@inclusion

            } else if (!string_contains(@userGroup, ':')) {
                @group = @userGroup

            } else {
                @splitedUserGroup = split(':', @userGroup)
                @group = @splitedUserGroup[0]
                @test = @splitedUserGroup[1]
                @filter[@group]['$all'] = !@inclusion
            }

            @filter[@group][@test] = @inclusion
        }

        @self['filter'] = @filter
        console(@filter)
    }

    @attributes['isTestGroup'] = closure(@m, @self, array @groups) {
        foreach(@group in @groups) {
            @filter = @self['filter']

            if (!_key_in(@filter, @group)) {
                @group = '$default'
            }

            foreach(@test: @value in @filter[@group]) {
                if (@value, return(true))
            }

            return(false)
        }
    }

    @attributes['isTestProc'] = closure(@m, @self, array @groups, string @test) {
        @filter = @self['filter']
        foreach(@group in @groups) { 
            if (!_key_in(@filter, @group)) {
                @group = '$default'
            }

            if (!_key_in(@filter[@group], @test)) {
                @test = '$all'
            }

            if (@filter[@group][@test]) {
                return(true)
            }
        }

        return(false)
    }

    _msunit_register_class('TestFilter', @attributes)
})

array proc _msunit_new_test_filter(array @options, array @grouper) {
    array @self = associative_array()

    foreach(@key: @attr in _msunit_get_class('TestFilter')) {
        @self[@key] = @attr
    }

    @self['options'] = @options
    @self['grouper'] = @grouper

    return(@self)
}

_msunit_include_add(closure() {
    array @attributes = associative_array()

    proc _defaultTrueCompile(@self) { 
        @filter = associative_array()

        @filter['$default']['$all'] = true

        return(@filter)
    }

    proc _defaultFalseCompile(@self) { 
        @filter = associative_array()

        @filter['$default']['$all'] = false

        return(@filter)
    }

    proc _compile(@self, array @userGroups) {
        if (array_size(@userGroups) == 0) {
            @self['filter'] = null
            return()
        }

        @filter = associative_array()
        @not = @self['options']['groups']['not']
        @grouper = @self['grouper']
        @userGroup = @userGroups[0]

        if(@userGroup[0] == @not) {
            @scripts = _method('getScripts', @grouper)
            foreach(@script in @scripts) {
                @tests = _method('getTestsGroup', @grouper, @script)
                foreach(@test in @tests) {
                    @filter[@script][@test] = true
                }
            }
        }

        foreach(@userGroup in @userGroups) {
            @inclusion = !string_contains(@userGroup, @not)

            @userGroup = reg_replace('['.@not.']', '', @userGroup)

            if (!string_contains(@userGroup, ':')) {
                @group = @userGroup
                @scripts = _method('getScriptsGroup', @grouper, @group)
                foreach(@script in @scripts) {
                    @tests = _method('getTestsGroup', @grouper, @script)
                    foreach(@test in @tests) {
                        @filter[@script][@test] = @inclusion
                    }
                }

            } else {
                @splitedUserGroup = split(':', @userGroup)
                @group = @splitedUserGroup[0]
                @test = @splitedUserGroup[1]

                @scripts = _method('getScriptsGroup', @grouper, @group)
                foreach(@script in @scripts) {
                    @filter[@script][@test] = @inclusion
                }
            }
        }

        @self['filter'] = @filter
    }

    proc _isChosenTest(@self, string @script, string @test) {
        @filter = @self['filter']
        if (@filter == null) {
            return(true)
        }
        
        if (!array_index_exists(@filter, @script, @test)) {
            return(false)
        }

        return(@filter[@script][@test])
    }

    proc _isChosenGroup(@self, string @script) {
        @filter = @self['filter']
        if (@filter == null) {
            return(true)
        }
        
        if (!array_index_exists(@filter, @script)) {
            return(false)
        }

        foreach(@test: @val in @filter[@script]) {
            if(@val) {
                return(true)
            }
        }

        return(false)
    }

    _msunit_register_class('TestFilter', @attributes, array(
        'defaultTrueCompile': '_defaultTrueCompile',
        'defaultFalseCompile': '_defaultFalseCompile',
        'compile': '_compile',
        'isChosenTest': '_isChosenTest',
        'isChosenGroup': '_isChosenGroup',
    ))
})

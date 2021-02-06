array proc _msunit_new_grouper(array @settingGroups, array @originTestsMap, array @options) {
    array @self = associative_array()

    foreach(@key: @attr in _msunit_get_class('Grouper')) {
        @self[@key] = @attr
    }

    @testsMap = associative_array()
    foreach(@formatScript: @groups in @settingGroups) {
        @testsMap[@formatScript] = @originTestsMap[@formatScript]
        foreach(@group in @groups) {
            if (!_key_in(@testsMap, @group)) {
                @testsMap[@group] = array()
            }
            
            @procs = array_filter(@originTestsMap[@formatScript], closure(@i, @p) {
                return(!_contains(@testsMap[@group], @p))
            })
            
            array_push_all(@testsMap[@group], @procs)
        }
    }

    @self['settingGroups'] = @settingGroups
    @self['testsMap'] = @testsMap
    @self['originTestsMap'] = @originTestsMap

    @completions = array()
    @not = @options['groups']['not']
    @test = @options['groups']['separator']
    foreach(@group: @procs in @testsMap) {
        foreach(@proc in @procs) {
            @completions[] = @group
            @completions[] = @not.@group
            @completions[] = @group.@test.@proc
            @completions[] = @not.@group.@test.@proc
        }
    }

    @allTests = array()
    @testsMap = @self['originTestsMap']
    foreach(@script: @tests in @testsMap) {
        array_push_all(@allTests, array_filter(@tests, closure(@i, @t) {return(!_contains(@allTests, @t))}))
    }
    
    array_push_all(@completions, array_map(@allTests, closure(@t) {return(@test.@t)}))
    array_push_all(@completions, array_map(@allTests, closure(@t) {return(@not.@test.@t)}))

    @self['completions'] = @completions

    return(@self)
}

_msunit_include_add(closure() {
    array @attributes = associative_array()

    @attributes['getScriptGroups'] = closure(@m, @self, string @script) {
        @formatScript = _method('formatScript', @self, @script)
        @settingGroups = @self['settingGroups']
        @groups = _get(@settingGroups, @formatScript)[]
        @groups[] = @formatScript
        return(@groups)
    }

    @attributes['getCompletions'] = closure(@m, @self) {
        return(@self['completions'])
    }

    @attributes['formatScript'] = closure(@m, @self, string @script) {
        return(reg_replace('.ms$', '', reg_replace('[\\\\/]', '.', @script)))
    }

    _msunit_register_class('Grouper', @attributes)
})

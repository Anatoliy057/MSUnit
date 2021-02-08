array proc _msunit_new_grouper(array @groupsScriptMap, array @testsScriptMap, array @options) {
    array @self = associative_array()

    foreach(@key: @attr in _msunit_get_class('Grouper')) {
        @self[@key] = @attr
    }

    @testsGroupMap = associative_array()
    foreach(@formatScript: @groups in @groupsScriptMap) {
        @groupsScriptMap[@formatScript][] = @formatScript
        if (!array_index_exists(@testsScriptMap, @formatScript)) {
            continue()
        }
        @testsGroupMap[@formatScript] = @testsScriptMap[@formatScript]
        foreach(@group in @groups) {
            if (!array_index_exists(@testsGroupMap, @group)) {
                @testsGroupMap[@group] = array()
            }
            
            @procs = array_filter(@testsScriptMap[@formatScript], closure(@i, @p) {
                return(!array_contains(@testsGroupMap[@group], @p))
            })
            
            array_push_all(@testsGroupMap[@group], @procs)
        }
    }

    @scriptsGroupMap = associative_array()
    foreach(@script: @groups in @groupsScriptMap) {
        foreach(@group in @groups) {
            if(!array_index_exists(@scriptsGroupMap, @group)) {
                @scriptsGroupMap[@group] = array_keys(
                    array_filter(@groupsScriptMap, closure(@s, @gps) {
                        return(array_contains(@gps, @group))
                    })
                )
            }
        }
        @scriptsGroupMap[@script] = array(@script)
    }

    @self['groupsScriptMap'] = @groupsScriptMap
    @self['scriptsGroupMap'] = @scriptsGroupMap
    @self['testsGroupMap'] = @testsGroupMap

    @completions = array()
    @not = @options['groups']['not']
    @separator = @options['groups']['separator']
    foreach(@group: @procs in @testsGroupMap) {
        foreach(@proc in @procs) {
            @completions[] = @group
            @completions[] = @not.@group
            @completions[] = @group.@separator.@proc
            @completions[] = @not.@group.@separator.@proc
        }
    }

    @self['completions'] = @completions

    return(@self)
}

_msunit_include_add(closure() {
    array @attributes = associative_array()

    @attributes['getGroupsScript'] = closure(@m, @self, string @script) {
        @formatScript = _method('formatScript', @self, @script)
        if(array_index_exists(@self['groupsScriptMap'], @formatScript)) {
            return(@self['groupsScriptMap'][@formatScript])
        } else {
            return(array())
        }
    }

    @attributes['getScriptsGroup'] = closure(@m, @self, string @group) {
        if(array_index_exists(@self['scriptsGroupMap'], @group)) {
            return(@self['scriptsGroupMap'][@group])
        } else {
            return(array())
        }
    }

    @attributes['getScripts'] = closure(@m, @self) {
        return(array_keys(@self['groupsScriptMap']))
    }

    @attributes['getGroups'] = closure(@m, @self) {
        return(array_keys(@self['testsGroupMap']))
    }

    @attributes['getTestsGroup'] = closure(@m, @self, string @group) {
        if(array_index_exists(@self['testsGroupMap'], @group)) {
            return(@self['testsGroupMap'][@group])
        } else {
            return(array())
        }
    }

    @attributes['getCompletions'] = closure(@m, @self) {
        return(@self['completions'])
    }

    @attributes['formatScript'] = closure(@m, @self, string @script) {
        return(reg_replace('.ms$', '', reg_replace('[\\\\/]', '.', @script)))
    }

    _msunit_register_class('Grouper', @attributes)
})

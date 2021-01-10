array proc _msunit_new_test_filter(array @moduleSetting, array @userGroups, array @scripts) {
    array @object = associative_array()

    foreach(@key: @attr in _msunit_import_class('Grouper')) {
        @object[@key] = @attr
    }

    @pattern = @moduleSetting['script']['patternName']
    @groupsMap = associative_array()

    foreach(@script in @scripts) {
        if (_reg_like(@pattern, @script)) {
            @key = _method('formatScript', @object, @script)
            @value = ''
            @groupsMap[@key] = @value
        }
    }

    foreach(@key: @value in @userGroups) {
        @groupsMap[@key] = @value
    }

    @object['groupsMap'] = @groups

    return(@object)
}

_msunit_include_add(closure() {

    array @attributes = associative_array()

    @attributes['getScriptGroups'] = closure(@m, @self, string @script) {
        @groupsMap = @self['groupsMap']
        @key = _method('formatScript', @object, @script)

        return(_get(@groupsMap, @key))
    }

    @attributes['getGroups'] = closure(@m, @self) {
        @groups = array()
        foreach(@key: @value in @self['groupsMap']) {
            @groups[] = @key
            
            foreach(@group in @value) {
                if(!_contains(@groups, @group)) {
                    @groups[] = @group
                }
            }
        }

        return(@groups)
    }

    @attributes['formatScript'] = closure(@m, @self, string @script) {
        return(reg_replace('/ms$', '', reg_replace('[\\\\/]', '.', @script)))
    }

    @attributes['unformatScript'] = closure(@m, @self, string @script) {
        return(reg_replace('\\.', '/', @script) + '.ms')
    }

    _msunit_register_class('Grouper', @attributes)
})

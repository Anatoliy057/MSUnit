array proc _msunit_new_grouper(array @moduleSetting, array @settingGroups, array @testsScripts) {
    array @object = associative_array()

    foreach(@key: @attr in _msunit_import_class('Grouper')) {
        @object[@key] = @attr
    }

    if (_is_empty(@settingGroups)) {
        foreach(@script in @tests) {
            @settingGroups[@script] = @setting['default_group']
        }
    }

    array @procsTests = associative_array()
    foreach(@script: @testScript in @testsScripts) {
        @procsTests[_method('formatScript', @self, @script)] = array_shallow_clone(@test['tests'])
    }

    @object['settingGroups'] = @settingGroups
    @object['procsTests'] = @procsTests
    @object['moduleSetting'] = @moduleSetting
    @object['pattern']

    return(@object)
}

_msunit_include_add(closure() {

    array @attributes = associative_array()

    @attributes['compile'] = closure(@m, @self, array @args) { 
        @not = @self['moduleSetting']['groups']['not']
        @in = @self['moduleSetting']['groups']['in']

       
    }

    @attributes['formatScript'] = closure(@m, @self, string @script) {
        return(reg_replace('/ms$', '', reg_replace('[\\\\/]', '.', @script)))
    }

    @attributes['unformatScript'] = closure(@m, @self, string @script) {
        return(reg_replace('\\.', '/', @script) + '.ms')
    }

    @attributes['getTestsScripts'] = closure(@m, @self, array @userGroups) {
        array @scripts = associative_array()
        foreach(@script: @groups in @self['settingGroups']) {
            if (array_some(@groups, closure(@group) {
                return(array_contains(@userGroups, @group))
            })) {
                @scripts[_method('unformatScript', @self, @script)] = @self['procsTests'][@script]
            }
        }

        return(@scripts)
    }

    @attributes['getGroups'] = closure(@m, @self) {
        array @groups = array()
        
        foreach(@script: @scriptGroups in @self['settingGroups']) {
            array_push_all(@groups, array_filter(@scriptGroups, closure(@index, @group) {
                return(!_contains(@groups, @group))
            }))
            @groups[] = @script
        }

        return(@groups)
    }

    @attributes['getPossibleProcedures'] = closure(@m, @self, array @userGroups) {
        array @procs = array()
        foreach(@script: @groups in @self['settingGroups']) {
            if (array_some(@groups, closure(@group) {
                return(array_contains(@userGroups, @group))
            })) {
                array_push_all(@procs, @self['tests'][@script])
            }
        }

        return(@procs)
    }

    _msunit_register_class('Grouper', @attributes)
})
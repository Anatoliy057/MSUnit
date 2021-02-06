array proc _msunit_get_groups_validator() {
    return(_msunit_get_class('GroupsValidation'))
}

_msunit_include_add(closure() {
    array @validator = associative_array()

    @validator['updateSettingGroups'] = closure(@m, @self, @settingGroups, array @scripts) {
        @updatedSettingGroups = array()

        if(!_is_empty(@settingGroups) && (!is_array(@settingGroups) || !is_associative(@settingGroups))) {
            return(@settingGroups)
        }

        foreach(@script in @scripts) {
            @formatScript = _msunit_static_method('formatScript', 'Grouper', @script)
            @updatedSettingGroups[@formatScript] = array()
        }

        foreach(@formatScript: @groups in @settingGroups) {
            @updatedSettingGroups[@formatScript] = @groups
        }

        return(@updatedSettingGroups)
    }

    @validator['validUserGroups'] = closure(@m, @self, array @userGroups, array @options) {
        @not = @options['groups']['not']
        @messager = _msunit_get_validation_messager()
        array @messages = array()

        foreach(@group in @userGroups) {
            if(
                !_reg_like('^['.@not.']?[\\-\\_\\w]+$', @group)
                && !_reg_like('^['.@not.']?[\\-\\_\\w]+:[\\-\\_\\w]+$', @group)
                && !_reg_like('^['.@not.']?:[\\-\\_\\w]+$', @group)
            ) {
                @messages[] = _method(
                    'fatal',
                    @messager,
                    "The specified group '@group' does not match the expression"
                )
            }
        }

        return(@messages)
    }

    @validator['validSettingGroups'] = closure(@m, @self, array @settingGroups, array @testsScripts) {
        @messager = _msunit_get_validation_messager()
        array @messages = array()

        @formatTestsScripts = array_map(@testsScripts, closure(@script) {
            return(_msunit_static_method('formatScript', 'Grouper', @script))
        })

        foreach(@scriptGroup: @groups in @settingGroups) {
            if (!_contains(@formatTestsScripts, @scriptGroup)) {
                @messages[] = _method(
                    'warn',
                    @messager,
                    "No such @scriptGroup script found"
                )
            }

            if(_reg_like(@scriptGroup, '[\\\\/]')) {
                @messages[] = _method(
                    'fatal',
                    @messager,
                    "The script name cannot contain file separators at @scriptGroup. Instead of them there should be '.'"
                )
            }

            if (is_array(@groups) && !is_associative(@groups)) {
                foreach(@group in @groups) {
                    _method('validGroup', @self, @messager, @messages, @group, @scriptGroup, @formatTestsScripts)
                }
            
            } else {
                @messages[] = _method(
                    'fatal',
                    @messager,
                    "Groups at script @scriptGroup must be array (not associative)"
                )
                
                continue()        
            }
        }

        return(@messages)
    }

    @validator['validGroup'] = closure(@m, @self, array @messager, array @messages, string @group, string @script, array @scripts) {
        if (!is_string(@group)) {
            @actually = typeof(@group)
            @expect = typeof('')
            @messages[] = _method(
                'fatal',
                @messager,
                "Group must be @expect, but @group at script @script"
            )
        
        } else if(_contains(@scripts, @group)) {
            @messages[] = _method(
                'fatal',
                @messager,
                "Group must be different from script names at script @script"
            )
        
        } else if(!_reg_like('\\w+', @group)) {
            @messages[] = _method(
                'fatal',
                @messager,
                "Group must be like '\\w+' at script @script"
            )
        }
    }

    _msunit_register_class('GroupsValidation', @validator)
})

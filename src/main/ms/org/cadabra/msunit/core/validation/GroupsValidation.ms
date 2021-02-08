array proc _msunit_get_groups_validator() {
    return(_msunit_get_class('GroupsValidation'))
}

_msunit_include_add(closure() {
    array @validator = associative_array()

    @validator['patternGroup'] = '[\\.\\_\\-\\w]+'

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

    @validator['validUserGroups'] = closure(@m, @self, array @userGroups, array @grouper, array @options) {
        @not = @options['groups']['not']
        @separator = @options['groups']['separator']
        @messager = _msunit_get_validation_messager()
        array @messages = array()

        @groups = _method('getGroups', @grouper)
        @pattern = '^['.@not.']?[\\.\\-\\_\\w]+('.@separator.'[\\_\\w]+)?$'

        foreach(@userGroup in @userGroups) {
            if (!_reg_like(@pattern, @userGroup)) {
                @messages[] = _method(
                    'fatal',
                    @messager,
                    "The specified argument '@userGroup' does not match the @pattern"
                )
                continue()
            }

            @userGroup = replace(@userGroup, @not, '')

            if(string_contains(@userGroup, @separator)) {
                @splitted = split(@separator, @userGroup)
                @group = @splitted[0]
                @test = @splitted[1]

                if (!_contains(@groups, @group)) {
                    @messages[] = _method(
                        'fatal',
                        @messager,
                        "The specified group '@userGroup' not exists"
                    )
                    continue()
                }
                
                @tests = _method('getTestsGroup', @grouper, @group)
                if (!_contains(@tests, @test)) {
                    @messages[] = _method(
                        'fatal',
                        @messager,
                        "The specified test '@test' not exists in group '@group'"
                    )
                }
            
            } else {
                if (!_contains(@groups, @userGroup)) {
                    @messages[] = _method(
                        'fatal',
                        @messager,
                        "The specified group '@userGroup' not exists"
                    )
                }
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
                    "No such '@scriptGroup' script found"
                )
            }

            @pattern = @self['patternGroup']
            if(!_reg_like(@pattern, @scriptGroup)) {
                @messages[] = _method(
                    'fatal',
                    @messager,
                    "The script-key '@scriptGroup' does not match the @pattern"
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
                    "Groups '@group' must be array (not associative) at @scriptGroup"
                )
                
                continue()        
            }
        }

        return(@messages)
    }

    @validator['validGroup'] = closure(@m, @self, array @messager, array @messages, @group, string @script, array @scripts) {
        @pattern = @self['patternGroup']
        if (!is_string(@group)) {
            @actually = typeof(@group)
            @expect = typeof('')
            @messages[] = _method(
                'fatal',
                @messager,
                "Group '@group' must be @expect, but @actually at @script"
            )
        
        } else if(_contains(@scripts, @group)) {
            @messages[] = _method(
                'fatal',
                @messager,
                "Group '@group' must be different from script-groups at @script"
            )
        
        } else if(!_reg_like(@pattern, @group)) {
            @messages[] = _method(
                'fatal',
                @messager,
                "Group '@group' does not match the @pattern at @script"
            )
        }
    }

    _msunit_register_class('GroupsValidation', @validator)
})

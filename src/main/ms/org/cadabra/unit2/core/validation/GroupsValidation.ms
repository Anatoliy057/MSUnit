array proc _msunit_get_script_validator() {
    import(_msunit_get_class('GroupsValidation'))
}

_msunit_include_add(closure() {
    array @validator = associative_array()

    @validator['validUserGroups'] = closure(@m, @self, array @userGroups, array @moduleSetting) {
        @message = _msunit_get_validation_message()
        array @messages = array()
        
        @not = @self['moduleSetting']['groups']['not']
        @in = @self['moduleSetting']['groups']['in']

        @pattern = "^([@not@int](([\\w+-]+$)|([:][\\w+-]+$)|([\\w+-]+[:][\\w+-]+$)))|(([\\w+-]+$)|([:][\\w+-]+$)|([\\w+-]+[:][\\w+-]+$))"

        foreach(@arg in @args) {
            if(!_reg_like(@pattern, @arg)) {
                @messages[] = _method(
                    'error',
                    @message,
                    "The specified group '@group' does not match the expression"
                )
            }
        }
        return(@messages)
    }

    @validator['validSettingGroups'] = closure(@m, @self, array @settingGroups, array @testsScripts) {
        @message = _msunit_get_validation_message()
        array @messages = array()

        @scripts = array_map(array_keys(@settingGroups), closure(@script) {
            return(_msunit_static_method('unformatScript', 'Grouper', @script))
        })

        foreach(@script: @groups in @settingGroups) {
            if (!_key_in(@scripts, @script)) {
                @messages[] = _method(
                    'warn',
                    @message,
                    "No such @script script found"
                )
            }

            if(_reg_like(@script, '[\\\\/]')) {
                @messages[] = _method(
                    'error',
                    @message,
                    "The script name cannot contain file separators at @script. Instead of them there should be dots"
                )
            }

            if (is_array(@groups)) {
                if (is_associative(@groups)) {
                    @messages[] = _method(
                        'error',
                        @message,
                        "Groups can not be in associative array at script @script"
                    )
                    continue()
                } else {
                    foreach(@group in @groups) {
                        _method('validGroup', @self, @message, @messages, @script, @scripts)
                    }
                }
            } else {
                _method('validGroup', @self, @message, @messages, @script, @scripts)
            }
        }

        return(@messages)
    }

    @validator['validGroup'] = closure(@m, @self, array @message, array @messages, string @group, string @script, array @scripts) {
        if (!is_string(@group)) {
            @actually = typeof(@group)
            @expect = typeof('')
            @messages[] = _method(
                'error',
                @message,
                "Group must be @expect, but @group at script @script"
            )
        } else if(_key_in(@scripts, @group)) {
            @messages[] = _method(
                'error',
                @message,
                "Group must be different from script names at script @script"
            )
        } else if(!_reg_like('\\w+', @group)) {
            @messages[] = _method(
                'error',
                @message,
                "Group must be like '\\w+' at script @script"
            )
        }
    }

    _msunit_register_class('GroupsValidation', @validator)
})

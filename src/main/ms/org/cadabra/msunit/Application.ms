array proc _msunit_get_application() {
    return(_msunit_get_class('Application'))
}

_msunit_include_add(closure() {
    array @app = associative_array()

    string @THREAD_NAME = '(MSUNIT) Tester thread'

    @app['testers'] = associative_array()

    @app['test'] = closure(@m, @self, string @id, string @caller, array @commandArguments) {
        if(!_key_in(@self['testers'], @id)) {
            msg(color('DARK_RED')."That module '@id' not register")
            die()
        }

        x_thread_join(@THREAD_NAME)

        x_new_thread(@THREAD_NAME, closure() {
            @tester = @self['testers'][@id]
            _method('test', @tester, @caller, @commandArguments)
        })
    }

    @app['start'] = closure(@m, @self) {
        _msunit_application_start()
        _method('registerTesters', @self)
        _method('registerCommand', @self)
    }

    @app['registerTesters'] = closure(@m, @self) {
        @modules = _msunit_import_modules()

        foreach(@id: @options in @modules) {
            @self['testers'][@id] = _msunit_new_tester(@id, @options)
        }
    }

    @app['registerTester'] = closure(@m, @self, string @id, array @options) {
        @self['testers'][@id] = _msunit_new_tester(@id, @options)
    }

    @app['registerCommand'] = closure(@m, @self) {
        register_command('unit', array(
            'description': 'MSUnit module control',
            'usage': '/unit <module> [groups...]',
            'aliases':array('unit'),
            'executor': closure(@alias, @caller, @args) {
                if(_size(@args) == 0) {
                    return(false)
                
                } else {
                    @id = @args[0]
                    @userGroups = if (_size(@args) == 1, array(), @args[1..-1])
                    _method('test', @self, @id, @caller, @userGroups)
                }
            })
        )

        set_tabcompleter('unit', closure(@alias, @sender, @args, @info) {
            return(_method('tabcompleter', @self, @alias, @sender, @args, @info))
        })
    }

    @app['tabcompleter'] = closure(@m, @self, @alias, @sender, @args, @info) {
        @input = @args[-1]
        if(array_size(@args) == 1) {
            return(
                array_filter(array_keys(@self['testers']),
                closure(@key, @value) {
                    return(
                        length(@input) <= length(@value) 
                        && equals_ic(@input, substr(@value, 0, length(@input)))
                    )
                })
            )
        
        } else if(array_size(@args) > 1) {
            @id = @args[0]
            @tester = @self['testers'][@id]
            
            return(_method('tabcompleter', @tester, @args))
        }
    }

    _msunit_register_class('Application', @app)
}) 

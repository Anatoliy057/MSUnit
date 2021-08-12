array proc _msunit_get_application() {
    return(_msunit_get_class('Application'))
}

_msunit_include_add(closure() {
    array @app = associative_array()

    @app['THREAD_NAME'] = '(MSUNIT) Tester thread'

    @app['testers'] = associative_array()

    proc _test(@self, string @id, string @caller, array @commandArguments) {
        if(!array_index_exists(@self['testers'], @id)) {
            msg(color('DARK_RED')."That module '@id' not register")
            die()
        }

        @THREAD_NAME = @self['THREAD_NAME']
        x_thread_join(@THREAD_NAME)
        x_new_thread(@THREAD_NAME, closure() {
            @tester = @self['testers'][@id]
            _method('test', @tester, @caller, @commandArguments)
        })
    }

    proc _start(@self) {
        _msunit_application_start()
        _method('registerTesters', @self)
        _method('registerCommand', @self)
    }

    proc _registerTesters(@self) {
        @options = _msunit_import_options()
        @modules = _msunit_import_modules()
        foreach(@id: @moduleSetting in @modules) {
            @self['testers'][@id] = _msunit_new_tester(@id, @moduleSetting, @options)
            console(array_keys(@self['testers'][@id]))
        }
    }

    proc _registerTester(@self, string @id, array @moduleSetting) {
        if(array_index_exists(@self['testers'], @id)) {
            throw(Exception, "That module '@id' already registered")
        }

        @options = _msunit_import_options()
        @self['testers'][@id] = _msunit_new_tester(@id, @moduleSetting, @options)
    }

    proc _registerCommand(@self) {
        register_command('unit', array(
            'description': 'MSUnit module control',
            'usage': '/unit <module> [--reinit] [--no-bar] [groups...]',
            'aliases':array('unit'),
            'executor': closure(@alias, @caller, @args) {
                if(array_size(@args) == 0) {
                    return(false)
                
                } else {
                    @id = @args[0]
                    @userGroups = if (array_size(@args) == 1, array(), @args[1..-1])
                    _method('test', @self, @id, @caller, @userGroups)
                }
            })
        )

        set_tabcompleter('unit', closure(@alias, @sender, @args, @info) {
            return(_method('tabcompleter', @self, @alias, @sender, @args, @info))
        })
    }

    proc _tabcompleter(@self, @alias, @sender, @args, @info) {
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

    _msunit_register_class('Application', @app, array(
        'test': '_test',
        'start': '_start',
        'registerTesters': '_registerTesters',
        'registerTester': '_registerTester',
        'registerCommand': '_registerCommand',
        'tabcompleter': '_tabcompleter',
    ))
}) 
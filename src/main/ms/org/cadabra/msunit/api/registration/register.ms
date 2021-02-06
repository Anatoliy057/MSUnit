proc _msunit_register_module(array @settings, array @options = null) {
    array @defaultOptions = _msunit_static_method('loadYml', 'ResourseLoader', 'setting')
    array @moduleSetting = @defaultOptions['module']

    @options = @options ||| array()

    string @root
    string @id

    if (_key_in(@settings, 'id')) {
        @id = @settings['id']

    } else {
        throw(NotFoundException, 'You must specify the "id"')
    }

    if (_key_in(@settings, 'root')) {
        @moduleSetting['root'] = @settings['root']
        @root = @settings['root']

        if (!is_dir(@root)) {
            throw(IllegalArgumentException, "Specify 'root' is not directory")
        }

    } else {
        throw(NotFoundException, 'You must specify the "root"')
    }

    if (_key_in(@settings, 'tests')) {
        @moduleSetting['rootTests'] = @root.'/'.@settings['tests']

    } else {
        @moduleSetting['rootTests'] = "@root/ms"
    }

    if (_key_in(@settings, 'resources')) {
        @moduleSetting['rootResources'] = @root.'/'.@settings['resources']

    } else {
        @moduleSetting['rootResources'] = "@root/resources"
    }

    if (_key_in(@settings, 'setting_groups')) {
        @moduleSetting['settingGroups'] = @root.'/'.@settings['setting_groups']
    
    } else {
        @moduleSetting['settingGroups'] = "@root/settings.yml"
    }

    if (_key_in(@settings, 'extension')) {
        @moduleSetting['extension'] = @root.'/'.@settings['extension'].'/main.ms'
    
    } else {
        @moduleSetting['extension'] = "@root/extension/main.ms"
    }

    @moduleSetting['rootTests'] = file_resolve(@moduleSetting['rootTests'])
    @moduleSetting['rootResources'] = file_resolve(@moduleSetting['rootResources'])
    @moduleSetting['settingGroups'] = file_resolve(@moduleSetting['settingGroups'])
    @moduleSetting['extension'] = file_resolve(@moduleSetting['extension'])

    _msunit_make_folder(@moduleSetting['rootTests'])
    _msunit_make_folder(@moduleSetting['rootResources'])
    _msunit_make_file(@moduleSetting['extension'])
    if(!file_exists(@moduleSetting['settingGroups'])) {
        _msunit_make_file(@moduleSetting['settingGroups'])
        write_file(@moduleSetting['settingGroups'], yml_encode(associative_array()))
    }

    if (_key_in(@settings, 'test_pattern')) {
        @moduleSetting['testPattern'] = @settings['test_pattern']
    
    } else {
        @moduleSetting['testPattern'] = '.*-test\\.ms$'
    }

    if (_key_in(@settings, 'outs')) {
        @outs = array()
        foreach(@out in @settings['outs']) {
            @outs[] = _msunit_new_out(@out)
        }

        @moduleSetting['outs'] = @outs

    } else {
        @moduleSetting['outs'] = _msunit_get_outs("@root/logs")
    }

    _msunit_replace_in_array(@defaultOptions, @options)

    if(!_msunit_is_application_started()) {
        @modules = _msunit_import_modules()
        if(_key_in(@modules, @id)) {
            throw(Exception, "That module '@id' already registered")
        }

        @modules[@id] = @defaultOptions

    } else {
        @app = _msunit_get_application()
        _method('registerTester', @app, @id, @defaultOptions)
    }
}

array proc _msunit_get_outs(string @pathToLog) {
    return(
        array(
            _msunit_new_out(
                closure(@text, @caller) {
                    if(@caller == '~console' || @caller == 'CONSOLE') {
                        console(@text, false)
                    
                    } else {
                        tmsg(@caller, @text)
                    }
                }
            ),
            _msunit_new_out(
                closure(@text) {
                    @pathToLog = file_resolve("@pathToLog/".simple_date('yyyy.MM.dd').'.log')
                    if (!file_exists(@pathToLog)) {
                        _msunit_make_file(@pathToLog)
                    }
                    
                    write_file(@pathToLog, strip_colors(@text), 'APPEND')
                    write_file(@pathToLog, '\n', 'APPEND')
                }
            )
        )
    )
}

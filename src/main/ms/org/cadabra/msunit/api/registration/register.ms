proc _msunit_register_module(array @settings, array @options = null) {
    array @defaultOptions = yml_decode(read(file_resolve(_msunit_import_resourse_root().'/setting.yml')))
    array @moduleSetting = @defaultOptions['module']

    @options = @options ||| array()

    string @root
    string @id

    if (array_index_exists(@settings, 'id')) {
        @id = @settings['id']

    } else {
        throw(NotFoundException, 'You must specify the "id"')
    }

    if (array_index_exists(@settings, 'root')) {
        @moduleSetting['root'] = @settings['root']
        @root = @settings['root']

        if (!is_dir(@root)) {
            throw(IllegalArgumentException, "Specify 'root' is not directory")
        }

    } else {
        throw(NotFoundException, 'You must specify the "root"')
    }

    if (array_index_exists(@settings, 'tests')) {
        @moduleSetting['rootTests'] = @root.'/'.@settings['tests']

    } else {
        @moduleSetting['rootTests'] = "@root/ms"
    }

    if (array_index_exists(@settings, 'resources')) {
        @moduleSetting['rootResources'] = @root.'/'.@settings['resources']

    } else {
        @moduleSetting['rootResources'] = "@root/resources"
    }

    if (array_index_exists(@settings, 'setting_groups')) {
        @moduleSetting['settingGroups'] = @root.'/'.@settings['setting_groups']
    
    } else {
        @moduleSetting['settingGroups'] = "@root/settings.yml"
    }

    if (array_index_exists(@settings, 'extension')) {
        @moduleSetting['extension'] = @root.'/'.@settings['extension'].'/main.ms'
        @moduleSetting['rootExtension'] = @root.'/'.@settings['extension']
    
    } else {
        @moduleSetting['extension'] = "@root/extension/main.ms"
        @moduleSetting['rootExtension'] = "@root/extension"
    }

    @moduleSetting['rootTests'] = file_resolve(@moduleSetting['rootTests'])
    @moduleSetting['rootResources'] = file_resolve(@moduleSetting['rootResources'])
    @moduleSetting['settingGroups'] = file_resolve(@moduleSetting['settingGroups'])
    @moduleSetting['extension'] = file_resolve(@moduleSetting['extension'])
    @moduleSetting['rootExtension'] = file_resolve(@moduleSetting['rootExtension'])

    _msunit_make_folder(@moduleSetting['rootTests'], @root)
    _msunit_make_folder(@moduleSetting['rootResources'], @root)
    _msunit_make_file(@moduleSetting['extension'], @root)
    if(!file_exists(@moduleSetting['settingGroups'])) {
        _msunit_make_file(@moduleSetting['settingGroups'], @root)
        write_file(@moduleSetting['settingGroups'], yml_encode(associative_array()))
    }

    if (array_index_exists(@settings, 'test_pattern')) {
        @moduleSetting['testPattern'] = @settings['test_pattern']
    
    } else {
        @moduleSetting['testPattern'] = '.*_test\\.ms$'
    }

    if (array_index_exists(@settings, 'outs')) {
        @outs = array()
        foreach(@out in @settings['outs']) {
            @outs[] = _msunit_new_out(@out)
        }

        @moduleSetting['outs'] = @outs

    } else {
        @moduleSetting['outs'] = _msunit_get_outs(@root)
    }

    _msunit_replace_in_array(@defaultOptions, @options)

    if(!_msunit_is_application_started()) {
        @modules = _msunit_import_modules()
        if(array_index_exists(@modules, @id)) {
            throw(Exception, "That module '@id' already registered")
        }

        @modules[@id] = @defaultOptions

    } else {
        @app = _msunit_get_application()
        _method('registerTester', @app, @id, @defaultOptions)
    }
}

array proc _msunit_get_outs(string @root) {
    return(
        array(
            closure(@text, @caller) {
                if(@caller == '~console' || @caller == 'CONSOLE') {
                    console(@text, false)
                
                } else {
                    tmsg(@caller, @text)
                }
            },
            closure(@text) {
                @pathToLog = file_resolve("@root/logs/".simple_date('yyyy.MM.dd').'.log')
                if (!file_exists(@pathToLog)) {
                    _msunit_make_file(@pathToLog, @root)
                }
                
                write_file(@pathToLog, strip_colors(@text), 'APPEND')
                write_file(@pathToLog, '\n', 'APPEND')
            }
        )
    )
}

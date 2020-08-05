execute(closure() {

    proc _set_default_commands(@s) {
        @s['default_commands'] = '-'.@s['commands']['update'].' '.@s['props']['default_group'].' -'.@s['commands']['run'].' '.@s['props']['default_group']
    }

    @init = 'init'
    @run = 'run'
    @update = 'update'

    @start = 'start'

    @delimiter = '|'
    @default_group = 'all'

    @colors = array(
        'test_successful': 'GREEN',
        'test_skip': 'YELLOW',
        'test_fail': 'RED',
        'default': 'GRAY',
        'script': 'WHITE',
        'test': 'WHITE',
        'time_successful': 'GREEN',
        'time_attention': 'YELLOW',
        'time_fail': 'RED',
        'message': 'YELLOW',
        'test_log': 'DARK_RED',
        'user_log': 'GRAY'
    )

    @limit_time = array(
        'successful': 0.1,
        'attention': 0.5
    )

    @setting_test = array(
        'assert_timeout' : 5,
        'proc_timeout' : 10,
        'number_threads' : 6,
        'pref_test_proc' : '_test',
        'pref_before_proc' : '_before_each',
        'pref_test_init_proc' : '_before_all',
        'pref_after_proc' : '_after_each',
        'pref_test_end_proc' : '_after_all',
        'colors': @colors,  
        'limit_time': @limit_time  
    )

    @setting = associative_array(
        version: 1,
        commands: array(
            init: @init,
            run: @run,
            update: @update,
            start: @start
        ),
        props: array(
            delimiter: @delimiter,
            default_group: @default_group
        ),
        tests: @setting_test
    )

    @path_to_setting = 'setting.yml'
    if (file_exists('setting.yml')) {
        @user_setting = yml_decode(read(@path_to_setting))
        proc _equals_construct(array @data, array @struct, string @path, boolean @strict) {
            @bool = true
            foreach(@key: @value in @struct) {
                if (!array_index_exists(@data, @key)) {
                    if (@strict) {
                        console("[MSUNIT] NotFoundException: Key '@key' missing in settings at ".if(@path, "@path.@key", @key), false)
                        @bool = false
                        continue()
                    } else {continue()}
                }
                if (typeof(@value) != typeof(@data[@key])) {
                    console('[MSUNIT] CastException: Except - '.typeof(@value).', actually - '.typeof(@data[@key]).' at '.if(@path, "@path.@key", @key), false)
                    @bool = false
                    continue()
                }
                if (is_array(@value)) {
                    @bool = @bool && _equals_construct(@data[@key], @value, if (@path, "@path.@key", @key))
                }
            }
            return(@bool)
        }
        if (!is_array(@user_setting) || !is_associative(@user_setting)) {
            console('[MSUNIT] CastException: Except - ms.lang.array[associative], actually - '.typeof(@user_setting).' at ./', false)
            console('[MSUNIT] Close.', false)
            die()
        }
        if (
            array_index_exists(@user_setting, 'version')
            && is_number(@user_setting['version'])
            && @user_setting['version'] == @setting['version']
        ) {
            if (_equals_construct(@user_setting, @setting, null, true)) {
                export('org.cadabra.msunit.setting', @user_setting)
            } else {
                console('[MSUNIT] Close.', false)
                die()
            }
        } else {
            if (!_equals_construct(@user_setting, @setting, null, false)) {
                console('[MSUNIT] Close.', false)
                die()
            }
            proc _update(array @user_setting, array @setting) {
                console(@arguments)
                foreach(@key: @value in @setting) {
                    if (!array_index_exists(@user_setting, @key)) {
                        @user_setting[@key] = @value
                    } else {
                        if (is_array(@value)) {
                            _update(@user_setting[@key], @value)
                        }
                    }
                }
                @keys = _util_array_minus(array_keys(@user_setting), array_keys(@setting))
                foreach(@key in @keys) {
                    array_remove(@user_setting, @key)
                }
            }
            _update(@user_setting, @setting)
            @user_setting['version'] = @setting['version']
            export('org.cadabra.msunit.setting', @user_setting)
        }
    } else {
        export('org.cadabra.msunit.setting', @setting)
    }
    write_file(@path_to_setting, yml_encode(import('org.cadabra.msunit.setting')), 'OVERWRITE')
    _set_default_commands(import('org.cadabra.msunit.setting'))
})
array proc _msunit_get_script_validator() {
    import(_msunit_get_class('ScriptValidator'))
}

_msunit_include_add(closure() {
    array @validator = associative_array()

    @validator['valid'] = closure(@m, @self, string @script, array @procs, array @setting) {
        @filter = _msunit_get_filter()

        @message = _msunit_get_validation_message()

        array @messages = array()

        @tests = _method('getTests', @filter, @procs, @setting)
        @beforeEach = _method('getBeforeEach', @filter, @procs, @setting)
        @beforeAll = _method('getBeforeAll', @filter, @procs, @setting)
        @afterEach = _method('getAfterEach', @filter, @procs, @setting)
        @afterAll = _method('getafterAll', @filter, @procs, @setting)
        @afterEachWithoutArgs = _method('getAfterEachWithoutArgs', @filter, @procs, @setting)
        @afterAllWithoutArgs = _method('getAfterAllWithoutArgs', @filter, @procs, @setting)

        @messages[] = _method('validTests', @self, @script, @tests, @procs, @message)
        @messages[] = _method('validBeforeEach', @self, @script, @beforeEach, @message)
        @messages[] = _method('validAfterEach', @self, @script, @afterEach, @afterEachWithoutArgs, @message)
        @messages[] = _method('validAfterAll', @self, @script, @afterAll, @afterAllWithoutArgs, @message)
        
        return(@messages)
    }

    @validator['validTests'] = closure(@m, @self, string @script, array @tests, array @procs, array @message) {
        if (_is_empty(@tests)) {
            if (_is_empty(@procs)) {
                return(_method(
                    'warn',
                    @message,
                    "Test '@script' without tests"
                ))
            } else {
                return(_method(
                    'fatal',
                    @message,
                    "Test '@script' without tests, but contains support procedures"
                ))
            }
        } else {
            return(_method('success', @message))
        }
    }

    @validator['validBeforeEach'] = closure(@m, @self, string @script, array @beforeEach, array @message) {
        if (_size(@beforeEach) > 1) {
            return(_method(
                'fatal',
                @message,
                "There is more than one beforeEach procedure in the script @script"
            ))
        }
    }

    @validator['validBeforeEach'] = closure(@m, @self, string @script, array @beforeAll, array @message) {
        if (_size(@beforeAll) > 1) {
            return(_method(
                'fatal',
                @message,
                "There is more than one beforeAll procedure in the script @script"
            ))
        }
    }

    @validator['validAfterEach'] = closure(@m, @self, string @script, array @afterEach, array @afterEachWithoutArgs, array @message) {
        if ((!_is_empty(@afterEach) && !_is_empty(@afterEachWithoutArgs)) || xor(_is_empty(@afterEach), _is_empty(@afterEachWithoutArgs))) {
            return(_method(
                'fatal',
                @message,
                "In the script @script exists at the same time afterEach and afterEachWithoutArgs"
            ))
        }

        if (_size(@afterEach) > 1) {
            return(_method(
                'fatal',
                @message,
                "There is more than one afterEach procedure in the script @script"
            ))
        }

        if (_size(@afterEachWithoutArgs) > 1) {
            return(_method(
                'fatal',
                @message,
                "There is more than one afterEachWithoutArgs procedure in the script @script"
            ))
        }
    }

    @validator['validAfterAll'] = closure(@m, @self, string @script, array @afterAll, array @afterAllWithoutArgs, array @message) {
        if ((!_is_empty(@afterAll) && !_is_empty(@afterAllWithoutArgs)) || xor(_is_empty(@afterAll), _is_empty(@afterAllWithoutArgs))) {
            return(_method(
                'fatal',
                @message,
                "In the script @script exists at the same time afterAll and afterAllWithoutArgs"
            ))
        }

        if (_size(@afterAll) > 1) {
            return(_method(
                'fatal',
                @message,
                "There is more than one afterAll procedure in the script @script"
            ))
        }

        if (_size(@afterAllWithoutArgs) > 1) {
            return(_method(
                'fatal',
                @message,
                "There is more than one afterAllWithoutArgs procedure in the script @script"
            ))
        }
    }

    _msunit_register_class('ScriptValidator', @filter)
})

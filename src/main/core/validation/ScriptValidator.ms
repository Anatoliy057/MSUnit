array proc _msunit_get_script_validator() {
    return(_msunit_get_class('ScriptValidator'))
}

_msunit_include_add(closure() {
    array @validator = associative_array()

    @validator['valid'] = closure(@m, @self, string @script, array @procs) {
        @messager = _msunit_get_validation_messager()

        array @messages = array()

        @tests = @procs['tests']
        @beforeEach = @procs['beforeEach']
        @beforeAll = @procs['beforeAll']
        @afterEach = @procs['afterEach']
        @afterAll = @procs['afterAll']

        @msg = _method('validTests', @self, @script, @tests, @messager)
        if(@msg != null) {
            @messages[] = @msg
        }
        
        @msg = _method('validBeforeEach', @self, @script, @beforeEach, @messager)
        if(@msg != null) {
            @messages[] = @msg
        }
        
        @msg = _method('validAfterEach', @self, @script, @afterEach, @messager)
        if(@msg != null) {
            @messages[] = @msg
        }
        
        @msg = _method('validAfterAll', @self, @script, @afterAll, @messager)
        if(@msg != null) {
            @messages[] = @msg
        }
        return(@messages)
    }

    @validator['validTests'] = closure(@m, @self, string @script, array @tests, array @messager) {
        if (array_size(@tests) == 0) {
            return(_method(
                'warn',
                @messager,
                "Test '@script' without tests"
            ))
            
        } else {
            return(null)
        }
    }

    @validator['validBeforeEach'] = closure(@m, @self, string @script, array @beforeEach, array @messager) {
        if (array_size(@beforeEach) > 1) {
            return(_method(
                'fatal',
                @messager,
                "There is more than one beforeEach procedure in the script @script"
            ))
        
        } else {
            return(null)
        }
    }

    @validator['validBeforeEach'] = closure(@m, @self, string @script, array @beforeAll, array @messager) {
        if (array_size(@beforeAll) > 1) {
            return(_method(
                'fatal',
                @messager,
                "There is more than one beforeAll procedure in the script @script"
            ))
        
        } else {
            return(null)
        }
    }

    @validator['validAfterEach'] = closure(@m, @self, string @script, array @afterEach, array @messager) { 
        if (array_size(@afterEach) > 1) {
            return(_method(
                'fatal',
                @messager,
                "There is more than one afterEach procedure in the script @script"
            ))
        
        } else {
            return(null)
        }
    }

    @validator['validAfterAll'] = closure(@m, @self, string @script, array @afterAll, array @messager) {
        if (array_size(@afterAll) > 1) {
            return(_method(
                'fatal',
                @messager,
                "There is more than one afterAll procedure in the script @script"
            ))
        
        } else {
            return(null)
        }
    }

    _msunit_register_class('ScriptValidator', @validator)
})

array proc _msunit_get_test() {
    import(_msunit_get_class('ProcsFilter'))
}

_msunit_include_add(closure() {
    array @filterProcs = associative_array()

    @filterProcs['filterProcs'] = closure(@m, @self, array @procs, array @setting) {
        @filteredProcs = associative_array()

        @filteredProcs['tests'] = _method('getTests', @self, @procs, @setting)
        @filteredProcs['beforeEach'] = _method('getBeforeEach', @self, @procs, @setting)
        @filteredProcs['beforeAll'] = _method('getBeforeAll', @self, @procs, @setting)
        @filteredProcs['afterEach'] = _method('getAfterEach', @self, @procs, @setting)
        @filteredProcs['afterAll'] = _method('getafterAll', @self, @procs, @setting)
        @filteredProcs['afterEachWithoutArgs'] = _method('getAfterEachWithoutArgs', @self, @procs, @setting)
        @filteredProcs['afterAllWithoutArgs'] = _method('getAfterAllWithoutArgs', @self, @procs, @setting)
    
        return(@filteredProcs)
    }

    @filterProcs['getTests'] = closure(@m, @self, array @procs, array @setting) {
        @filter = @setting['script']['test']

        return(_method('filter', @self, @procs, @filter))
    }

    @filterProcs['getBeforeEach'] = closure(@m, @self, array @procs, array @setting) {
        @filter = @setting['script']['beforeEach']

        return(_method('filter', @self, @procs, @filter))
    }

    @filterProcs['getBeforeAll'] = closure(@m, @self, array @procs, array @setting) {
        @filter = @setting['script']['beforeAll']

        return(_method('filter', @self, @procs, @filter))
    }

    @filterProcs['getAfterEach'] = closure(@m, @self, array @procs, array @setting) {
        @filter = @setting['script']['afterEach']

        return(_method('filter', @self, @procs, @filter))
    }

    @filterProcs['getAfterAll'] = closure(@m, @self, array @procs, array @setting) {
        @filter = @setting['script']['afterAll']

        return(_method('filter', @self, @procs, @filter))
    }

    @filterProcs['getAfterEachWithoutArgs'] = closure(@m, @self, array @procs, array @setting) {
        @filter = @setting['script']['afterEachWithoutArgs']

        return(_method('filter', @self, @procs, @filter))
    }

    @filterProcs['getAfterAllWithoutArgs'] = closure(@m, @self, array @procs, array @setting) {
        @filter = @setting['script']['afterAllWithoutArgs']

        return(_method('filter', @self, @procs, @filter))
    }

    @filterProcs['filter'] = closure(@m, @self, array @procs, string @filter) {
        return(array_filter(@procs, closure(@key, @value) {
            return(reg_count(@filter, @value) != 0)
        }))
    }

    _msunit_register_class('ProcsFilter', @filter)
})

array proc _msunit_get_procs_sorter() {
    return(_msunit_get_class('ProcsFilter'))
}

_msunit_include_add(closure() {
    array @filterProcs = associative_array()

    @filterProcs['filterProcs'] = closure(@m, @self, array @procs, array @options) {
        @filteredProcs = associative_array()

        @filteredProcs['tests'] = _method('getTests', @self, @procs, @options)
        @filteredProcs['beforeEach'] = _method('getBeforeEach', @self, @procs, @options)
        @filteredProcs['beforeAll'] = _method('getBeforeAll', @self, @procs, @options)
        @filteredProcs['afterEach'] = _method('getAfterEach', @self, @procs, @options)
        @filteredProcs['afterAll'] = _method('getAfterAll', @self, @procs, @options)
    
        return(@filteredProcs)
    }

    @filterProcs['getTests'] = closure(@m, @self, array @procs, array @options) {
        @filter = @options['test']['procs']['test']

        return(_method('filter', @self, @procs, @filter))
    }

    @filterProcs['getBeforeEach'] = closure(@m, @self, array @procs, array @options) {
        @filter = @options['test']['procs']['beforeEach']

        return(_method('filter', @self, @procs, @filter))
    }

    @filterProcs['getBeforeAll'] = closure(@m, @self, array @procs, array @options) {
        @filter = @options['test']['procs']['beforeAll']

        return(_method('filter', @self, @procs, @filter))
    }

    @filterProcs['getAfterEach'] = closure(@m, @self, array @procs, array @options) {
        @filter = @options['test']['procs']['afterEach']

        return(_method('filter', @self, @procs, @filter))
    }

    @filterProcs['getAfterAll'] = closure(@m, @self, array @procs, array @options) {
        @filter = @options['test']['procs']['afterAll']

        return(_method('filter', @self, @procs, @filter))
    }

    @filterProcs['filter'] = closure(@m, @self, array @procs, string @filter) {
        return(array_filter(@procs, closure(@key, @value) {
            return(_reg_like(@filter, @value))
        }))
    }

    _msunit_register_class('ProcsFilter', @filterProcs)
})

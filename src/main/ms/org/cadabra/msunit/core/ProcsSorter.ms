array proc _msunit_get_procs_sorter() {
    return(_msunit_get_class('ProcsSorter'))
}

_msunit_include_add(closure() {
    array @procsSorter = associative_array()

    @procsSorter['sortProcs'] = closure(@m, @self, array @procs, array @options) {
        @filteredProcs = associative_array()

        @filteredProcs['tests'] = _method('getTests', @self, @procs, @options)
        @filteredProcs['beforeEach'] = _method('getBeforeEach', @self, @procs, @options)
        @filteredProcs['beforeAll'] = _method('getBeforeAll', @self, @procs, @options)
        @filteredProcs['afterEach'] = _method('getAfterEach', @self, @procs, @options)
        @filteredProcs['afterAll'] = _method('getAfterAll', @self, @procs, @options)
    
        return(@filteredProcs)
    }

    @procsSorter['getTests'] = closure(@m, @self, array @procs, array @options) {
        @filter = @options['test']['procs']['test']

        return(_method('filter', @self, @procs, @filter))
    }

    @procsSorter['getBeforeEach'] = closure(@m, @self, array @procs, array @options) {
        @filter = @options['test']['procs']['beforeEach']

        return(_method('filter', @self, @procs, @filter))
    }

    @procsSorter['getBeforeAll'] = closure(@m, @self, array @procs, array @options) {
        @filter = @options['test']['procs']['beforeAll']

        return(_method('filter', @self, @procs, @filter))
    }

    @procsSorter['getAfterEach'] = closure(@m, @self, array @procs, array @options) {
        @filter = @options['test']['procs']['afterEach']

        return(_method('filter', @self, @procs, @filter))
    }

    @procsSorter['getAfterAll'] = closure(@m, @self, array @procs, array @options) {
        @filter = @options['test']['procs']['afterAll']

        return(_method('filter', @self, @procs, @filter))
    }

    @procsSorter['filter'] = closure(@m, @self, array @procs, string @filter) {
        return(array_filter(@procs, closure(@key, @value) {
            return(_reg_like(@filter, @value))
        }))
    }

    _msunit_register_class('ProcsSorter', @procsSorter)
})

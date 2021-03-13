array proc _msunit_get_procs_sorter() {
    return(_msunit_get_class('ProcsSorter'))
}

_msunit_include_add(closure() {
    array @procsSorter = associative_array()

    @procsSorter['sortProcs'] = closure(@m, @self, array @procs, array @testsSetting) {
        @filteredProcs = associative_array()

        @filteredProcs['tests'] = _method('getTests', @self, @procs, @testsSetting)
        @filteredProcs['beforeEach'] = _method('getBeforeEach', @self, @procs, @testsSetting)
        @filteredProcs['beforeAll'] = _method('getBeforeAll', @self, @procs, @testsSetting)
        @filteredProcs['afterEach'] = _method('getAfterEach', @self, @procs, @testsSetting)
        @filteredProcs['afterAll'] = _method('getAfterAll', @self, @procs, @testsSetting)
    
        return(@filteredProcs)
    }

    @procsSorter['getTests'] = closure(@m, @self, array @procs, array @testsSetting) {
        @filter = @testsSetting['procs']['test']

        return(_method('filter', @self, @procs, @filter))
    }

    @procsSorter['getBeforeEach'] = closure(@m, @self, array @procs, array @testsSetting) {
        @filter = @testsSetting['procs']['beforeEach']

        return(_method('filter', @self, @procs, @filter))
    }

    @procsSorter['getBeforeAll'] = closure(@m, @self, array @procs, array @testsSetting) {
        @filter = @testsSetting['procs']['beforeAll']

        return(_method('filter', @self, @procs, @filter))
    }

    @procsSorter['getAfterEach'] = closure(@m, @self, array @procs, array @testsSetting) {
        @filter = @testsSetting['procs']['afterEach']

        return(_method('filter', @self, @procs, @filter))
    }

    @procsSorter['getAfterAll'] = closure(@m, @self, array @procs, array @testsSetting) {
        @filter = @testsSetting['procs']['afterAll']

        return(_method('filter', @self, @procs, @filter))
    }

    @procsSorter['filter'] = closure(@m, @self, array @procs, string @filter) {
        return(array_filter(@procs, closure(@key, @value) {
            return(_reg_like(@filter, @value))
        }))
    }

    _msunit_register_class('ProcsSorter', @procsSorter)
})

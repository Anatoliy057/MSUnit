array proc _msunit_get_procs_sorter() {
    return(_msunit_get_class('ProcsSorter'))
}

_msunit_include_add(closure() {
    array @procsSorter = associative_array()

    proc _sortProcs(@self, array @procs, array @testsSetting) {
        @filteredProcs = associative_array()

        @filteredProcs['tests'] = _method('getTests', @self, @procs, @testsSetting)
        @filteredProcs['beforeEach'] = _method('getBeforeEach', @self, @procs, @testsSetting)
        @filteredProcs['beforeAll'] = _method('getBeforeAll', @self, @procs, @testsSetting)
        @filteredProcs['afterEach'] = _method('getAfterEach', @self, @procs, @testsSetting)
        @filteredProcs['afterAll'] = _method('getAfterAll', @self, @procs, @testsSetting)
    
        return(@filteredProcs)
    }

    proc _getTests(@self, array @procs, array @testsSetting) {
        @filter = @testsSetting['procs']['test']

        return(_method('filter', @self, @procs, @filter))
    }

    proc _getBeforeEach(@self, array @procs, array @testsSetting) {
        @filter = @testsSetting['procs']['beforeEach']

        return(_method('filter', @self, @procs, @filter))
    }

    proc _getBeforeAll(@self, array @procs, array @testsSetting) {
        @filter = @testsSetting['procs']['beforeAll']

        return(_method('filter', @self, @procs, @filter))
    }

    proc _getAfterEach(@self, array @procs, array @testsSetting) {
        @filter = @testsSetting['procs']['afterEach']

        return(_method('filter', @self, @procs, @filter))
    }

    proc _getAfterAll(@self, array @procs, array @testsSetting) {
        @filter = @testsSetting['procs']['afterAll']

        return(_method('filter', @self, @procs, @filter))
    }

    proc _filter(@self, array @procs, string @filter) {
        return(array_filter(@procs, closure(@key, @value) {
            return(_reg_like(@filter, @value))
        }))
    }

    _msunit_register_class('ProcsSorter', @procsSorter, array(
        'sortProcs': '_sortProcs',
        'getTests': '_getTests',
        'getBeforeEach': '_getBeforeEach',
        'getBeforeAll': '_getBeforeAll',
        'getAfterEach': '_getAfterEach',
        'getAfterAll': '_getAfterAll',
        'filter': '_filter',
    ))
})

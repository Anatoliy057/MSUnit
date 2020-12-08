array proc _msunit_get_test() {
    import(_msunit_get_class('TestEntity'))
}

_msunit_include_add(closure() {
    array @filterProcs = associative_array()

    @filterProcs['filter'] = closure(@m, @self, array @procs, string @filter) {
        return(array_filter(@procs, closure(@key, @value) {
            return(reg_count(@filter, @value) != 0)
        }))
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

    _msunit_register_class('ProcsFilter', @filter)
})
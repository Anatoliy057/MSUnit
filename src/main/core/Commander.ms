array proc _msunit_get_commander() {
    return(_msunit_get_class('Commander'))
}

_msunit_include_add(closure() {
    array @commander = associative_array()

    @commander['patternCommand'] = '^[\\-]+.*'

    @commander['doCommands'] = closure(@m, @self, array @tester, array @userArgs) {
        @flags = associative_array()
        @pattern = @self['patternCommand']
        @indexesToRemove = array()
        for(@i = 0, @i < array_size(@userArgs), @i++) {
            @arg = @userArgs[@i]
            if(_reg_like(@pattern, @arg)) {
                if(array_index_exists(@self, @arg)) {
                    @indexesToRemove[] = @i
                    @flags[@arg] = _method(@arg, @self, @tester, @userArgs, @i, @indexesToRemove)
                }
            }
        }
        
        @offset = 0
        foreach(@index in @indexesToRemove) {
            array_remove(@userArgs, @index - @offset)
            @offset++
        }

        return(@flags)
    }

    @commander['--reinit'] = closure(@m, @self, array @tester, array @userArgs, int @pos, array @indexesToRemove) {        
        @moduleSetting = @tester['moduleSetting']
        x_recompile_includes(@moduleSetting['rootExtension'])
        x_recompile_includes(@moduleSetting['rootTests'])
        _method('init', @tester)
    }

    @commander['--no-bar'] = closure(@m, @self, array @tester, array @userArgs, int @pos, array @indexesToRemove) {
        return(true)
    }

    @commander['--save-data'] = closure(@m, @self, array @tester, array @userArgs, int @pos, array @indexesToRemove) {
        return(true)
    }

    @commander['--no-globals'] = closure(@m, @self, array @tester, array @userArgs, int @pos, array @indexesToRemove) {
        return(true)
    }

    @commander['getCommands'] = closure(@m, @self) {
        @pattern = @self['patternCommand']
        return(array_filter(array_keys(@self), closure(@i, @key) {return(_reg_like(@pattern, @key))}))
    }

    _msunit_register_class('Commander', @commander)
})

array proc _msunit_get_commander() {
    return(_msunit_get_class('Commander'))
}

_msunit_include_add(closure() {
    array @commander = associative_array()

    @commander['-command'] = closure(@m, @self, array @tester, array @userArgs) {
        @indexesToRemove = array()
        for(@i = 0, @i < array_size(@userArgs), @i++) {
            @arg = @userArgs[@i]
            if(_reg_like('^[\\-]+.*', @arg)) {
                @command = reg_replace('[\\-]', '', @arg)
                if(array_index_exists(@self, @command)) {
                    _method(@command, @self, @tester, @userArgs, @i, @indexesToRemove)
                }
            }
        }
        @offset = 0
        foreach(@index in @indexesToRemove) {
            array_remove(@userArgs, @index - @offset)
            @offset++
        }
    }

    @commander['reinit'] = closure(@m, @self, array @tester, array @userArgs, int @pos, array @indexesToRemove) {
        @indexesToRemove[] = @pos
        
        @moduleSetting = @tester['moduleSetting']
        x_recompile_includes(@moduleSetting['rootExtension'])
        x_recompile_includes(@moduleSetting['rootTests'])
        _method('init', @tester)
    }

    @commander['-getCommands'] = closure(@m, @self) {
        return(array('--reinit'))
    }

    _msunit_register_class('Commander', @commander)
})
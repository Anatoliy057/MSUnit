proc _unit_run(string @arg, array @setting) {
    _package_unit_commands_init(@setting)
    @commander = _package_unit_commands_get()
    
    @args = _util_split_arg(@arg, '-')

    @size = array_size(@args)
    for(@i = 0, @i < @size, @i++) {
        _util_commander_execute(@commander, @args[@i][0], @args[@i][1])
    }
}
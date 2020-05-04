# __unit_msg - messages for logs
# __unit_log - result of tests
# __unit_synchron - objects for synchronize


if (!file_exists(@UNIT_PATH_MSG)) {
    console("CHUnit: [FATAL] file '@{UNIT_PATH_MSG}' of msgs doesn't exist\n\t\t\t\tSure that path is correct.")
    die()
} else {
    export('__unit_msg', json_decode(read(@UNIT_PATH_MSG)))
}
export('__unit_synchron', array())
export('__unit_log', array())

proc _package_unit_get_msg(@key) {
    @msg = import('__unit_msg')
    if (array_size(@arguments) == 1) {
        return(@msg['prefix'].@msg[@key])
    } else {
        return(sprintf(@msg['prefix'].@msg[@key], @arguments[1..]))
    }
}

proc _package_unit_get_clear_msg(@key) {
    @msg = import('__unit_msg')
    if (array_size(@arguments) == 1) {
        return(@msg[@key])
    } else {
        return(sprintf(@msg[@key], @arguments[1..]))
    }
}

proc _package_unit_get_log() {
    return(import('__unit_log'))
}

proc _package_unit_get_cur_log() {
    @id = _package_unit_get_id_thread()
    return(_package_unit_get_log()[@id[0]][@id[1]])
}

proc _package_unit_get_id_thread() {
    return(split(':', _util_get_cur_thread()))
}

proc _package_unit_get_syn_o(@key) {
    return(import('__unit_synchron')[@key])
}

proc _package_unit_set_syn_o(string @o) {
    @monitor =  '__unit_synchron_'.@o
    import('__unit_synchron')[@o] = @monitor
    return(@monitor)
}
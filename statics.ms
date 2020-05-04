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
    if (array_size(@arguments) == 0) {
        return(@msg['prefix'].@msg[@key])
    } else {
        @msg = import('__unit_msg')
        return(sprintf(@msg['prefix'].@msg[@key], @arguments[1..]))
    }
}

proc _package_unit_get_log() {
    return(import('__unit_log'))
}

proc _package_unit_get_cur_log() {
    @id = split(':', _util_get_cur_thread())
    return(_package_unit_get_log()[@id[0]][@id[1]])
}

proc _package_unit_get_syn_timer(@script) {
    return(import('__unit_synchron')[@script])
}

proc _package_unit_set_syn_o(string @o) {
    import('__unit_synchron')[@o] = '__unit_synchron_'.@o
}
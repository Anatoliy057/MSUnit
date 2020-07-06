proc _unit_env_cur() {
    @id = _package_unit_static_get_id_thread()
    return(_unit_env_get(@id))
}

proc _unit_env_get(array @id) {
    return(_unit_env_global_get()[@id[0]][@id[1]])
}

proc _unit_env_init_cur(array @log, array @setting) {
    @log['user_log'] = res_create_resource('STRING_BUILDER')
    @log['test_log'] = ''
    @log['user_message'] = null
    @log['successful'] = true
    @log['skipped'] = false
    @log['time_assert'] = @setting['assert_timeout']
    @log['time_proc'] = @setting['proc_timeout']
    @log['assert_timeout'] = @setting['assert_timeout']
    @log['proc_timeout'] = @setting['proc_timeout']
}

proc _unit_env_global_get() {
    return(import('org.cadabra.msunit.env'))
}

export('org.cadabra.msunit.env', array())
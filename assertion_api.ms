proc _print(@msg) {
    @log = _unit_env_cur()()
    string_append(@log['user_log'], @msg)
}

proc _println(@msg) {
    @log = _unit_env_cur()()
    string_append(@log['user_log'], @msg)
    string_append(@log['user_log'], '\n')
}

proc _sleep(int @seconds) {
    @monitor = _package_unit_syn_get(_package_unit_static_get_name_thread())
    synchronized(@monitor) {
        sleep(@seconds)
    }
}

proc _assert_true(boolean @bool) {
    @monitor = _package_unit_syn_get(_package_unit_static_get_name_thread())
    synchronized(@monitor) {
        _private_assert_eq(true, @bool, 1)
    }
}

proc _assert_false(boolean @bool) {
    @monitor = _package_unit_syn_get(_package_unit_static_get_name_thread())
    synchronized(@monitor) {
        _private_assert_eq(false, @bool, 1)
    }
}

proc _assert_null(mixed @object) {
    @monitor = _package_unit_syn_get(_package_unit_static_get_name_thread())
    synchronized(@monitor) {
        _private_assert_eq(null, @object, 1)
    }
}

proc _assert_not_null(mixed @object) {
    @monitor = _package_unit_syn_get(_package_unit_static_get_name_thread())
    synchronized(@monitor) {
        _private_assert_not_eq(null, @object, 1)
    }
}

proc _assert_equals(mixed @exp, mixed @act) {
    @monitor = _package_unit_syn_get(_package_unit_static_get_name_thread())
    synchronized(@monitor) {
        _private_assert_eq(@exp, @act, 1)
    }
}

proc _assert_not_equals(mixed @arg1, mixed @arg2) {
    @monitor = _package_unit_syn_get(_package_unit_static_get_name_thread())
    synchronized(@monitor) {
        _private_assert_not_eq(@arg1, @arg2, 1)
    }
}

proc _assert_size(int @size, array @arr) {
    @monitor = _package_unit_syn_get(_package_unit_static_get_name_thread())
    synchronized(@monitor) {
        _private_assert_eq(@size, array_size(@arr), 1)
    }
}

proc _assert_length(int @length, mixed @act) {
    @monitor = _package_unit_syn_get(_package_unit_static_get_name_thread())
    synchronized(@monitor) {
        _private_assert_eq(@length, length(@act), 1)
    }
}

proc _assert_empty(mixed @object) {
    @monitor = _package_unit_syn_get(_package_unit_static_get_name_thread())
    synchronized(@monitor) {
        _private_assert_eq(0, length(@object), 1)
    }
}

proc _assert_not_empty(mixed @object) {
    @monitor = _package_unit_syn_get(_package_unit_static_get_name_thread())
    synchronized(@monitor) {
        _private_assert_not_eq(0, length(@object), 1)
    }
}

proc _assert_type(string @type, mixed @object) {
    @monitor = _package_unit_syn_get(_package_unit_static_get_name_thread())
    synchronized(@monitor) {
        _private_assert_eq(@type, typeof(@object), 1)
    }
}

proc _assert_proc_throw(string @classType, string @proc_name) {
    @args = null
    @act_type = null
    if (array_size(@arguments) > 2) {
        @args = @arguments[2..]
    }
    try {
        call_proc(@proc_name, @args)
    } catch (Exception @e) {
        @act_type = @e['classType']
    }

    @monitor = _package_unit_syn_get(_package_unit_static_get_name_thread())
    synchronized(@monitor) {
        _private_assert_eq(@classType, @act_type, 1)
    }
}

proc _assert_closure_throw(string @classType, closure @lymda) {
    @args = null
    @act_type = null
    if (array_size(@arguments) > 2) {
        @args = @arguments[2..]
    }
    try {
        execute(@args, @lymda)
    } catch (Exception @e) {
        @act_type = @e['classType']
    }

    @monitor = _package_unit_syn_get(_package_unit_static_get_name_thread())
    synchronized(@monitor) {
        _private_assert_eq(@classType, @act_type, 1)
    }
}

proc _assert_proc_does_not_throw(string @proc_name) {
    @log = _unit_env_cur()
    _private_assert_syn_restart_time(@log)
    @args = null
    @act_type = null
    if (array_size(@arguments) > 2) {
        @args = @arguments[2..]
    }
    try {
        call_proc(@proc_name, @args)
    } catch (Exception @e) {
        _private_assert_fail(@log, 'throw', 1, @e['classType'])
    }
    _private_assert_successful(@log)
}

proc _assert_closure_does_not_throw(closure @lymda) {
    @log = _unit_env_cur()
    _private_assert_syn_restart_time(@log)
    @args = null
    @act_type = null
    if (array_size(@arguments) > 2) {
        @args = @arguments[2..]
    }
    try {
        execute(@args, @lymda)
    } catch (Exception @e) {
        _private_assert_fail(@log, 'throw', 1, @e['classType'])
    }
    _private_assert_successful(@log)
}

proc _private_assert_successful(@log) {
    @log['successful'] = true
}

proc _private_assert_eq(@exp, @act, @stack) {
    @log = _unit_env_cur()
    _private_assert_restart_time(@log)
    if (@exp == @act) {
        _private_assert_successful(@log)
    } else {
        _private_assert_fail(@log, 'diff', @stack + 1, @exp, @act)
    }
}

proc _private_assert_not_eq(@arg1, @arg2, @stack) {
    @log = _unit_env_cur()
    _private_assert_restart_time(@log)
    if (@arg1 != @arg2) {
        _private_assert_successful(@log)
    } else {
        _private_assert_fail(@log, 'undiff', @stack + 1, @arg1, @arg2)
    }
}

proc _private_assert_fail(@log, @mode, @stack) {
    @builder = _unit_log_init_self()
    // _unit_log_set_trace(@builder, array_filter(get_stack_trace(), closure(@key, @val) {
    //     return(@val['id'][..8] != '_assert_' || @val['id'][..16] != '_private_assert_')
    // }))
    @trace = get_stack_trace()
    _unit_log_set_trace(@builder, @trace[cslice(@stack, array_size(@trace)-2)])
    _unit_log_set_def_cause(@builder, 'assert_fail')
    if (array_size(@arguments) < 4) {
        _unit_log_set_type_msg(@builder, @mode, array())
    } else {
        _unit_log_set_type_msg(@builder, @mode, @arguments[3..])
    }
    @log['test_log'] = _unit_log_build(@builder)
    @log['successful'] = false
    die()
}

proc _private_assert_restart_time(@log) {
    @log['assert_timeout'] = integer(@log['time_assert'])
}

proc _private_assert_syn_restart_time(@log) {
    @monitor = _package_unit_syn_get(_package_unit_static_get_name_thread())
    synchronized(@monitor) {
        _private_assert_restart_time(@log)
    }
}
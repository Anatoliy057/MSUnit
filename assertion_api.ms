proc _print(@msg) {
    @monitor = _package_unit_syn_get(_package_unit_static_get_name_thread())
    synchronized(@monitor) {
        @log = _unit_env_cur()()
        string_append(@log['user_log'], @msg)
    }
}

proc _println(@msg) {
    @monitor = _package_unit_syn_get(_package_unit_static_get_name_thread())
    synchronized(@monitor) {
        @log = _unit_env_cur()()
        string_append(@log['user_log'], @msg)
        string_append(@log['user_log'], '\n')
    }
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
        _private_assert_eq(true, @bool)
    }
}

proc _assert_false(boolean @bool) {
    @monitor = _package_unit_syn_get(_package_unit_static_get_name_thread())
    synchronized(@monitor) {
        _private_assert_eq(false, @bool)
    }
}

proc _assert_equals(mixed @exp, mixed @act) {
    @monitor = _package_unit_syn_get(_package_unit_static_get_name_thread())
    synchronized(@monitor) {
        _private_assert_eq(@exp, @act)
    }
}

proc _assert_size(int @size, array @arr) {
    @monitor = _package_unit_syn_get(_package_unit_static_get_name_thread())
    synchronized(@monitor) {
        _private_assert_eq(@size, array_size(@arr))
    }
}

proc _assert_length(int @length, mixed @act) {
    @monitor = _package_unit_syn_get(_package_unit_static_get_name_thread())
    synchronized(@monitor) {
        _private_assert_eq(@length, length(@act))
    }
}

proc _assert_emty(mixed @object) {
    @monitor = _package_unit_syn_get(_package_unit_static_get_name_thread())
    synchronized(@monitor) {
        _private_assert_eq(0, length(@object))
    }
}

proc _assert_type(string @type, mixed @object) {
    @monitor = _package_unit_syn_get(_package_unit_static_get_name_thread())
    synchronized(@monitor) {
        _private_assert_eq(@type, typeof(@object))
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
        _private_assert_eq(@classType, @act_type)
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
        _private_assert_eq(@classType, @act_type)
    }
}

proc _assert_proc_does_not_throw(string @classType, string @proc_name) {
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
        _private_assert_fail(@log, 'throw', @e['classType'])
    }
    _private_assert_successful(@log)
}

proc _assert_closure_does_not_throw(string @classType, closure @lymda) {
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
        _private_assert_fail(@log, 'throw', @e['classType'])
    }
    _private_assert_successful(@log)
}

proc _private_assert_successful(@log) {
    @log['successful'] = true
}

proc _private_assert_eq(@exp, @act) {
    @log = _unit_env_cur()
    _private_assert_restart_time(@log)
    if (@exp == @act) {
        _private_assert_successful(@log)
    } else {
        _private_assert_fail(@log, 'diff', @exp, @act)
    }
}

proc _private_assert_fail(@log, @mode) {
    @builder = _unit_log_init_self()
    _unit_log_set_trace(@builder, get_stack_trace())
    _unit_log_set_def_cause(@builder, 'assert_fail')
    switch(@mode) {
        case 'result':
            _unit_log_set_result(@builder, @arguments[2])
            break()
        case 'diff':
            _unit_log_set_diff(@builder, array(@arguments[2], @arguments[3]))
            break()
        case 'orig':
            _unit_log_set_msg(@builder, @arguments[2])
            break()
        case 'throw':
            _unit_log_set_type_msg(@builder, 'throw' @arguments[2])
            break()
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
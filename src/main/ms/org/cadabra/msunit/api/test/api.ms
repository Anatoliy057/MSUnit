if(is_proc('_unit')) {

proc _x_safe(closure @lymda) {
    x_safe_execute(@lymda)
}

proc _print(mixed @msg) {
    @state = _get_state_test()
    @userLog = @state['userLog']
    string_append(@userLog, @msg)
}

proc _println(mixed @msg = '') {
    @state = _get_state_test()
    @userLog = @state['userLog']
    string_append(@userLog, @msg)
    string_append(@userLog, '\n')
}

proc _sleep(int @seconds) {
    synchronized(x_get_current_thread()) {
        sleep(@seconds)
    }
}

proc _assert_time(int @seconds) {
    @state = _get_state_test()
    synchronized(x_get_current_thread()) {
        @state['assertTime'] = @seconds
    }
}

proc _test_time(int @seconds) {
    @state = _get_state_test()
    synchronized(x_get_current_thread()) {
        @state['testTime'] = @seconds
    }
}

proc _attension_time(int @attensionTime) {
    @state = _get_state_test()
    @state['attensionTime'] = @attensionTime
}

proc _skip_test() {
    @state = _get_state_test()
    @state['skipped'] = true
    
    die()
}

proc _assert_ref_eq(mixed @val1, mixed @val2, mixed @msg = null) {
    if (ref_equals(@val1, @val2)) {
        @stackTrace = get_stack_trace()
        _assert_diff_fail(@val1, @val2, @stackTrace, @msg)
    
    } else {
        _restart_assert_time()
    }
}

proc _assert_not_ref_eq(mixed @val1, mixed @val2, mixed @msg = null) {
    if (!ref_equals(@val1, @val2)) {
        @stackTrace = get_stack_trace()
        _assert_undiff_fail(@val1, @val2, @stackTrace, @msg)
    
    } else {
        _restart_assert_time()
    }
}

proc _assert_true_obj(Booleanish @o, mixed @msg = null) {
    if (!@o) {
        @stackTrace = get_stack_trace()
        _assert_custom_fail("Object '@o' is not in true state", @stackTrace, @msg)
    
    } else {
        _restart_assert_time()
    }
}

proc _assert_false_obj(Booleanish @o, mixed @msg = null) {
    if (@o) {
        @stackTrace = get_stack_trace()
        _assert_custom_fail("Object '@o' is in true state", @stackTrace, @msg)
    
    } else {
        _restart_assert_time()
    }
}

proc _assert_true(boolean @bool, mixed @msg = null) {
    if (@bool != true) {
        @stackTrace = get_stack_trace()
        _assert_diff_fail(true, @bool, @stackTrace, @msg)
    
    } else {
        _restart_assert_time()
    }
}

proc _assert_false(boolean @bool, mixed @msg = null) {
    if (@bool != false) {
        @stackTrace = get_stack_trace()
        _assert_diff_fail(false, @bool, @stackTrace, @msg)
    
    } else {
        _restart_assert_time()
    }
}

proc _assert_null(mixed @object, mixed @msg = null) {
    if (@object != null) {
        @stackTrace = get_stack_trace()
        _assert_diff_fail(null, @object, @stackTrace, @msg)
    
    } else {
        _restart_assert_time()
    }
}

proc _assert_not_null(mixed @object, mixed @msg = null) {
    if (@object == null) {
        @stackTrace = get_stack_trace()
        _assert_undiff_fail(null, @object, @stackTrace, @msg)
    
    } else {
        _restart_assert_time()
    }
}

proc _assert_equals(mixed @exp, mixed @act, mixed @msg = null) {
    if (@exp != @act) {
        @stackTrace = get_stack_trace()
        _assert_diff_fail(@exp, @act, @stackTrace, @msg)
    
    } else {
        _restart_assert_time()
    }
}

proc _assert_not_equals(mixed @exp, mixed @act, mixed @msg = null) {
    if (@exp == @act) {
        @stackTrace = get_stack_trace()
        _assert_undiff_fail(@exp, @act, @stackTrace, @msg)
    
    } else {
        _restart_assert_time()
    }
}

proc _assert_size(int @size, array @arr, mixed @msg = null) {
    if (@size != array_size(@arr)) {
        @stackTrace = get_stack_trace()
        _assert_diff_fail(@size, array_size(@arr), @stackTrace, @msg)
    
    } else {
        _restart_assert_time()
    }
}

proc _assert_length(int @length, mixed @object, mixed @msg = null) {
    if (@length != length(@object)) {
        @stackTrace = get_stack_trace()
        _assert_diff_fail(@length, length(@object), @stackTrace, @msg)
    
    } else {
        _restart_assert_time()
    }
}

proc _assert_empty(mixed @object, mixed @msg = null) {
    if (0 != length(@object)) {
        @stackTrace = get_stack_trace()
        _assert_custom_fail("Actually object is not empty: @object", @stackTrace, @msg)
    
    } else {
        _restart_assert_time()
    }
}

proc _assert_not_empty(mixed @object, mixed @msg = null) {
    if (0 == length(@object)) {
        @stackTrace = get_stack_trace()
        _assert_custom_fail('Actually object is empty', @stackTrace, @msg)
    
    } else {
        _restart_assert_time()
    }
}

proc _assert_type(ClassType @type, mixed @object, mixed @msg = null) {
    if (@type != typeof(@object)) {
        @stackTrace = get_stack_trace()
        _assert_diff_fail(@type, typeof(@object), @stackTrace, @msg)
    
    } else {
        _restart_assert_time()
    }
}

proc _assert_key_exist(string @key, array @array, mixed @msg = null) {
    if (!is_associative(@array)) {
        throw(CastException, 'Array not associative')
    }
    
    if (!_key_in(@array, @key)) {
        @stackTrace = get_stack_trace()
        _assert_custom_fail("Key '@key' not contains in ".array_keys(@array), @stackTrace, @msg)
    
    } else {
        _restart_assert_time()
    }
}

proc _assert_key_not_exist(string @key, array @array, mixed @msg = null) {
    if (!is_associative(@array)) {
        throw(CastException, 'Array not associative')
    }
    
    if (_key_in(@array, @key)) {
        @stackTrace = get_stack_trace()
        _assert_custom_fail("Key '@key' contains in ".array_keys(@array), @stackTrace, @msg)
    
    } else {
        _restart_assert_time()
    }
}

proc _assert_proc_array_throw(ClassType @type, string @proc, array @args, mixed @msg = null) {
    @exceptionType = null
    try {
        call_proc_array(@proc, @args)
    
    } catch (Exception @e) {
        @exceptionType = @e['classType']
    }
    
    if (@exceptionType == null) {
        @stackTrace = get_stack_trace()
        _assert_custom_fail('No exception been thrown', @stackTrace, @msg)
    
    } else {
        if (@type != @exceptionType) {
            @stackTrace = get_stack_trace()
            _assert_diff_fail(@type, @exceptionType, @stackTrace, @msg)
        
        } else {
            _restart_assert_time()
        }
    }
}

proc _assert_closure_array_throw(ClassType @type, closure @lymda, array @args, mixed @msg = null) {
    @exceptionType = null
    try {
        execute_array(@lymda, @args)
    
    } catch (Exception @e) {
        @exceptionType = @e['classType']
    }
    
    if (@exceptionType == null) {
        @stackTrace = get_stack_trace()
        _assert_custom_fail('No exception been thrown', @stackTrace, @msg)
    
    } else {
        if (@type != @exceptionType) {
            @stackTrace = get_stack_trace()
            _assert_diff_fail(@type, @exceptionType, @stackTrace, @msg)
        
        } else {
            _restart_assert_time()
        }
    }
}

proc _assert_proc_throw(ClassType @type, string @proc, mixed @msg = null) {
    @exceptionType = null
    try {
        call_proc(@proc)
    
    } catch (Exception @e) {
        @exceptionType = @e['classType']
    }
    
    if (@exceptionType == null) {
        @stackTrace = get_stack_trace()
        _assert_custom_fail('No exception been thrown', @stackTrace, @msg)
    
    } else {
        if (@type != @exceptionType) {
            @stackTrace = get_stack_trace()
            _assert_diff_fail(@type, @exceptionType, @stackTrace, @msg)
        
        } else {
            _restart_assert_time()
        }
    }
}

proc _assert_closure_throw(ClassType @type, closure @lymda, mixed @msg = null) {
    @exceptionType = null
    try {
        @lymda()
    
    } catch (Exception @e) {
        @exceptionType = @e['classType']
    }
    
    if (@exceptionType == null) {
        @stackTrace = get_stack_trace()
        _assert_custom_fail('No exception been thrown', @stackTrace, @msg)
    
    } else {
        if (@type != @exceptionType) {
            @stackTrace = get_stack_trace()
            _assert_diff_fail(@type, @exceptionType, @stackTrace, @msg)
        
        } else {
            _restart_assert_time()
        }
    }
}

proc _assert_custom_fail(string @causeFail, array @stackTrace, mixed @msg) {
    @assert = @stackTrace[0]['id']
    @testMessage =  "Assert @assert fail\n"
                    ."Cause: @causeFail"

    _assert_fail(@testMessage, @stackTrace, @msg)
}

proc _assert_diff_fail(@exp, @act, array @stackTrace, mixed @msg) {
    @assert = @stackTrace[0]['id']
    @testMessage =  "Assert @assert fail\n"
                    ."Difference: expect - @exp, actually - @act"

    _assert_fail(@testMessage, @stackTrace, @msg)
}

proc _assert_undiff_fail(@exp, @act, array @stackTrace, mixed @msg) {
    @assert = @stackTrace[0]['id']
    @testMessage =  "Assert @assert fail\n"
                    ."Difference: unexpect - @exp, actually - @act"

    _assert_fail(@testMessage, @stackTrace, @msg)
}

proc _assert_fail(string @testMessage, array @stackTrace, mixed @msg) {
    @stackTrace = @stackTrace[1..-2]
    
    @state = _get_state_test()
    @state['successful'] = false
    @state['testMessage'] = @testMessage
    @state['assertMessage'] = @msg
    @state['stackTrace'] = @stackTrace

    die()
}

proc _restart_assert_time(@log) {
    @state = _get_state_test()
    synchronized(x_get_current_thread()) {
        @state['assertTime'] = @state['ASSERT_TIME']
    }
}

proc _get_state_test() {
    return(_msunit_get_state_environment())
}

proc _unit_get_resource(string @filename) {
    @root = _msunit_get_environment()['setting']['rootResources']
    return(file_resolve("@root/@filename"))
}

void proc _msunit_set_environment(array @setting, array @states) {
    export('org.cadabra.msunit.environment', array(
        setting: @setting,
        states: @states,
    ))
}

void proc _msunit_clear_environment() {
    export('org.cadabra.msunit.environment', null)
}

array proc _msunit_get_state_environment() {
    @id = _msunit_parse_thread()
    @states = _msunit_get_environment()['states']
    return(@states[@id['trimScript']][@id['test']])
}

array proc _msunit_get_environment() {
    return(import('org.cadabra.msunit.environment'))
}

}

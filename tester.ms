proc _package_unit_tester(@tests, @path_to_test, @setting, @out) {

    include('synchron.ms')
    include('environment.ms')

    @task_ex = _util_task_ex_init_self('__unit_thread_starting_tests', @setting['number_threads'], 1, false)
    @result = _unit_env_global_get()
    foreach(@test in @tests) {
        _private_unit_tester_add_test(@test, @path_to_test, @setting, @result, @task_ex)
    }
    @size = _util_task_ex_size_waiting(@task_ex)
    _util_task_ex_start(@task_ex)
    while(_util_task_ex_complited(@task_ex) != @size) {}
    _util_task_ex_stop(@task_ex)
    _private_unit_tester_log_result(@setting, @result, @out)
}

proc _private_unit_tester_add_test(string @test, string @path_to_test, array @setting, array @result, array @task_ex) {
    @path = @path_to_test.'\\'.replace(@test, '.', '\\').'.ms'
    @procs = array()
    if (file_exists(@path)) {
        @old_procs = get_procedures()
        include(@path)
        @new_procs = get_procedures()
        @procs = _util_array_minus(@new_procs, @old_procs)
    } else {
        console(_package_unit_msg_module_log('script_not_found', @test), false)
        return()
    }
    @sorted_procs = _private_unit_tester_sep_procs(@test, @procs, @setting)
    if (@sorted_procs == null) {
        return()
    }
    @task = _private_unit_tester_init_task(@test, @sorted_procs, @setting, @result)
    _util_task_ex_add(@task_ex, @task)
}

proc _private_unit_tester_sep_procs(string @script, array @procs, array @setting) {
    @sorted_procs = _private_unit_tester_sort_procs(@procs, @setting)
    if (array_size(@sorted_procs['before_each']) > 1) {
        console(_package_unit_msg_module_log('collision_proc_before_each', @script, @setting['pref_before_proc'], @sorted_procs['before_each']), false)
        return(null)
    } else if (array_size(@sorted_procs['before_all']) > 1) {
        console(_package_unit_msg_module_log('collision_proc_before_all', @script, @setting['pref_test_init_proc'], @sorted_procs['before_all']), false)
        return(null)
    } else if (array_size(@sorted_procs['tests']) == 0) {
        console(_package_unit_msg_module_log('procs_test_not_found', @setting['pref_test_proc'], @script), false)
        return(null)
    }
    return(@sorted_procs)
}

proc _private_unit_tester_init_task(string @test, array @sorted_procs, @setting, @result) {
    @result[@test] = array()
    @runnable = closure() {
        @lymda_before
        @lymda_each
        @before_all
        @before_each

        @tests = @sorted_procs['tests']
    
        if (@sorted_procs['before_all'] == null || array_size(@sorted_procs['before_all']) == 0) {
            @lymda_before = '_package_unit_undef_proc'
        } else {
            @lymda_before = @sorted_procs['before_all'][0]
        }
        if (@sorted_procs['before_each'] == null || array_size(@sorted_procs['before_each']) == 0) {
            @lymda_each = '_package_unit_undef_proc'
        } else {
            @lymda_each = @sorted_procs['before_each'][0]
        }
        try {
            @before_all = call_proc(@lymda_before)
        } catch (Exception @e) {
            console(_package_unit_msg_module_log(
                'error_before_all',
                @lymda_before,
                @e['classType'],
                @e['message'],
                _util_parse_stack_trace(1, @e['stackTrace'], 1)
            ), false)
            die()
        }
        for(@i = 0, @i < array_size(@tests), @i ++) {
            @proc_test = @tests[@i]
            try {
                @before_each = call_proc(@lymda_each)
            } catch (Exception @e) {
                console(_package_unit_msg_module_log(
                    'error_before_each',
                    @lymda_each,
                    @e['classType'],
                    @e['message'],
                    _util_parse_stack_trace(1, @e['stackTrace'], 1)
                ), false)
                die()
            } 

            @result[@test][@proc_test] = array()
            @res = @result[@test][@proc_test]
            _unit_env_init_cur(@res, @setting)
            
            @name_thread = @test.':'.@proc_test
            @motitor = _package_unit_syn_set(@name_thread)
            @name_thread = _package_unit_static_to_unit_thread(@name_thread)

            x_new_tracked_thread(@name_thread, closure() {
                @res['time'] = -nano_time()
                try {
                    call_proc(@proc_test, @before_all, @before_each)
                } catch(Exception @e) {
                    @res['successful'] = false
                    @e['stackTrace'] = @e['stackTrace'][..-2]
                    @res['test_log'] = _package_unit_log_unex_throw(@e)
                } finally {
                    @res['time'] += nano_time()
                    @res['time'] /= 1000000000
                }
            })

            @id_interval = _util_interval(1, 0, closure() {
                synchronized(@motitor) {
                    @res['assert_timeout'] -= 1
                    @res['proc_timeout'] -= 1
                }
            })

            while (tracked_thread_is_alive(@name_thread)) {
                if (@res['assert_timeout'] <= 0 && tracked_thread_is_alive(@name_thread)) {
                    x_stop_tracked_thread(@name_thread)
                    @res['successful'] = false
                    @res['test_log'] = _package_unit_log_assert_timeout()
                    break()
                }
                if (@res['proc_timeout'] <= 0  && tracked_thread_is_alive(@name_thread)) {
                    x_stop_tracked_thread(@name_thread)
                    @res['successful'] = false
                    @res['test_log'] = _package_unit_log_proc_timeout()
                    break()
                }
            }
            _util_clear_interval(@id_interval)
        }
    }
    return(@runnable)
} 

proc _private_unit_tester_sort_procs(@procs, @setting) {
    @sorted_procs = array()
    @sorted_procs['tests'] = array()
    @sorted_procs['before_each'] = array()
    @sorted_procs['before_all'] = array()
    foreach(@proc in @procs) {
        @len = length(@setting['pref_test_proc'])
        if (length(@proc) >= @len && @proc[cslice(0, @len-1)] == @setting['pref_test_proc']) {
            array_push(@sorted_procs['tests'], @proc)
        } else {
            @len = length(@setting['pref_before_proc'])
            if (length(@proc) >= @len && @proc[cslice(0, @len-1)] == @setting['pref_before_proc']) {
                array_push(@sorted_procs['before_each'], @proc)
            } else {
                @len = length(@setting['pref_test_init_proc'])
                if (length(@proc) >= @len && @proc[cslice(0, @len-1)] == @setting['pref_test_init_proc']) {
                    array_push(@sorted_procs['before_all'], @proc)
                }
            }
        }
    }
    return(@sorted_procs)
}

proc _private_unit_tester_log_result(@setting, @result, @outs) {
    foreach(@out in @outs) {
        int @count_tests = 0
        int @count_failures = 0
        if (!@out['enable'], continue())
        @builder = res_create_resource('STRING_BUILDER')
        string_append(@builder, '\n[TIME] ')
        string_append(@builder, '['.@setting['name_module'].'] ')
        string_append(@builder,  simple_date('yyyy.MM.dd \'at\' HH:mm:ss'))
        string_append(@builder, '\n')
        if (@out['short'] == true) {
            foreach(@script: @tests in @result) {
                string_append(@builder, '\n\n######################################################\n')
                string_append(@builder, 'Script: ')
                string_append(@builder, @script)
                string_append(@builder, '\n')
                foreach(@test: @info in @tests) {
                    @count_tests++
                    string_append(@builder, '\n------------------------------------------------------\n')
                    if (@info['successful']) {
                        string_append(@builder, '+ ')
                    } else {
                        @count_failures++
                        string_append(@builder, '- ')
                    }
                    string_append(@builder, 'Test: ')
                    string_append(@builder, @test)
                    string_append(@builder, sprintf(' - status: %s, time %f.\n', @info['successful'], @info['time']))
                    if (@info['user_message'] != null) {
                        string_append(@builder, 'Message: ')
                        string_append(@builder, @info['user_message'])
                        string_append(@builder, '\n')
                    }
                    @user_log = string(@info['user_log'])
                    if (@user_log != '') {
                        string_append(@builder, @user_log)
                        string_append(@builder, '\n')
                    }
                }
            }
            string_append(@builder, '\n')
            string_append(@builder, "Tests run: @count_tests, Failures: @count_failures")
        } else {
            foreach(@script: @tests in @result) {
                string_append(@builder, '\n\n######################################################\n')
                string_append(@builder, 'Script: ')
                string_append(@builder, @script)
                string_append(@builder, '\n')
                foreach(@test: @info in @tests) {
                    @count_tests++
                    string_append(@builder, '\n------------------------------------------------------\n')
                    if (@info['successful']) {
                        string_append(@builder, '+ ')
                    } else {
                        @count_failures++
                        string_append(@builder, '- ')
                    }
                    string_append(@builder, 'Test: ')
                    string_append(@builder, @test)
                    string_append(@builder, sprintf(' - status: %s, time %f.\n', @info['successful'], @info['time']))
                    if (@info['user_message'] != null) {
                        string_append(@builder, 'Message: ')
                        string_append(@builder, @info['user_message'])
                        string_append(@builder, '\n')
                    }
                    @user_log = string(@info['user_log'])
                    if (@user_log != '') {
                        string_append(@builder, @user_log)
                        string_append(@builder, '\n')
                    }
                    if (!@info['successful']) {
                        string_append(@builder, @info['test_log'])
                        string_append(@builder, '\n')  
                    }
                }
            }
            string_append(@builder, '\n')
            string_append(@builder, "Tests run: @count_tests, Failures: @count_failures")   
        }
        string_append(@builder, '\n')
        execute(string(@builder), @out['write'])
    }
}
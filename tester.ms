proc _package_unit_tester(@tests, @path_to_test, @setting, @outs) {
    include('synchron.ms')
    include('environment.ms')
    @task_ex = _util_tasker_init_self('org.cadabra.msunit.tester-thread', @setting['number_threads'], 1, false)
    @result = _unit_env_global_get()
    foreach(@test in @tests) {
        _private_unit_tester_add_test(@test, @path_to_test, @setting, @result, @task_ex)
    }
    @size = _util_tasker_size_waiting(@task_ex)
    @time = -nano_time()
    _util_tasker_start(@task_ex)
    while(_util_tasker_complited(@task_ex) != @size) {}
    _util_tasker_stop(@task_ex)
    @time += nano_time()
    @time /= 1000000000
    _private_unit_tester_log_result(@setting, @result, @time, @outs)
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
    _util_tasker_add(@task_ex, @task)
}

proc _private_unit_tester_sep_procs(string @script, array @procs, array @setting) {
    @sorted_procs = _private_unit_tester_sort_procs(@procs, @setting)
    if (array_size(@sorted_procs['before_each']) > 1) {
        console(_package_unit_msg_module_log('collision_proc_before_each', @script, @setting['pref_before_proc'], @sorted_procs['before_each']), false)
        return(null)
    } else if (array_size(@sorted_procs['before_all']) > 1) {
        console(_package_unit_msg_module_log('collision_proc_before_all', @script, @setting['pref_test_init_proc'], @sorted_procs['before_all']), false)
        return(null)
    } else if (array_size(@sorted_procs['after_each']) > 1) {
        console(_package_unit_msg_module_log('collision_proc_after_each', @script, @setting['pref_after_proc'], @sorted_procs['after_each']), false)
        return(null)
    } else if (array_size(@sorted_procs['after_all']) > 1) {
        console(_package_unit_msg_module_log('collision_proc_after_all', @script, @setting['pref_test_end_proc'], @sorted_procs['after_all']), false)
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
        string @lymda_before_all
        string @lymda_before_each
        string @lymda_after_all
        string @lymda_after_each
        mixed @before_all

        @tests = @sorted_procs['tests']
    
        if (@sorted_procs['before_all'] == null || array_size(@sorted_procs['before_all']) == 0) {
            @lymda_before_all = '_package_unit_undef_proc'
        } else {
            @lymda_before_all = @sorted_procs['before_all'][0]
        }
        if (@sorted_procs['before_each'] == null || array_size(@sorted_procs['before_each']) == 0) {
            @lymda_before_each = '_package_unit_undef_proc'
        } else {
            @lymda_before_each = @sorted_procs['before_each'][0]
        }
        if (@sorted_procs['after_all'] == null || array_size(@sorted_procs['after_all']) == 0) {
            @lymda_after_all = '_package_unit_undef_proc'
        } else {
            @lymda_after_all = @sorted_procs['after_all'][0]
        }
        if (@sorted_procs['after_each'] == null || array_size(@sorted_procs['after_each']) == 0) {
            @lymda_after_each = '_package_unit_undef_proc'
        } else {
            @lymda_after_each = @sorted_procs['after_each'][0]
        }

        try {
            @before_all = call_proc(@lymda_before_all)
        } catch (Exception @e) {
            console(_package_unit_msg_module_log(
                'error_before_all',
                @lymda_before_all,
                @e['classType'],
                @e['message'],
                string(_util_parse_stack_trace(1, @e['stackTrace'], 1))
            ), false)
            die()
        }
        for(@i = 0, @i < array_size(@tests), @i ++) {
            @proc_test = @tests[@i]
            synchronized('org.cadabra.msunit.result') {
                @result[@test][@proc_test] = array()
            }
            @res = @result[@test][@proc_test]
            _unit_env_init_cur(@res, @setting)
            
            @name_thread = @test.':'.@proc_test
            @motitor = _package_unit_syn_set(@name_thread)
            @name_thread = _package_unit_static_to_unit_thread(@name_thread)
            x_new_thread(@name_thread, closure() {
                @res['time'] = -nano_time()
                try {
                    @before_each = null
                    @return = null
                    @before_each = call_proc(@lymda_before_each)
                    if (@lymda_after_each == '_package_unit_undef_proc') {
                        call_proc(@proc_test, @before_all, @before_each)
                    } else {
                        @return = call_proc(@proc_test, @before_all, @before_each)
                        call_proc(@lymda_after_each, @return)
                    }
                } catch(Exception @e) {
                    @exception = array()
                    if (array_size(@e['stackTrace']) == 1) {
                        @builder = _unit_log_init_self()
                        _unit_log_set_def_cause(@builder, 'no_return')
                        @res['test_log'] = _unit_log_build(@builder)
                        @res['successful'] = false
                    } else {
                        @exception['classType'] = @e['classType']
                        @exception['message'] = @e['message']
                        @exception['stackTrace'] = @e['stackTrace'][..-2]
                        @res['successful'] = false
                        @res['test_log'] = _package_unit_log_unex_throw(@exception)
                    }
                } finally {
                    @res['time'] += nano_time()
                    @res['time'] /= 1000000000
                }
            })
            @id_interval = _util_interval(1, 0, closure() {
                synchronized(@motitor) {
                    @res['assert_timeout'] -= 1
                    @res['proc_timeout'] -= 1

                    if (@res['assert_timeout'] <= 0) {
                        x_stop_thread(@name_thread)
                        @res['successful'] = false
                        @res['test_log'] = _package_unit_log_assert_timeout()
                    }
                    if (@res['proc_timeout'] <= 0) {
                        x_stop_thread(@name_thread)
                        @res['successful'] = false
                        @res['test_log'] = _package_unit_log_proc_timeout()
                    }
                }
            })
            while (x_thread_is_alive(@name_thread)) {}
            _util_clear_interval(@id_interval)
        }
        try {
            call_proc(@lymda_after_all)
        } catch (Exception @e) {
            console(_package_unit_msg_module_log(
                'error_after_all',
                @lymda_after_all,
                @e['classType'],
                @e['message'],
                string(_util_parse_stack_trace(1, @e['stackTrace'], 1))
            ), false)
            die()
        }
    }
    return(@runnable)
} 

proc _private_unit_tester_sort_procs(@procs, @setting) {
    @sorted_procs = array()
    @sorted_procs['tests'] = array()
    @sorted_procs['before_each'] = array()
    @sorted_procs['before_all'] = array()
    @sorted_procs['after_each'] = array()
    @sorted_procs['after_all'] = array()
    foreach(@proc in @procs) {
        @len = length(@setting['pref_test_proc'])
        if (length(@proc) >= @len && @proc[cslice(0, @len-1)] == @setting['pref_test_proc']) {
            @sorted_procs['tests'][] = @proc
        } else {
            @len = length(@setting['pref_before_proc'])
            if (length(@proc) >= @len && @proc[cslice(0, @len-1)] == @setting['pref_before_proc']) {
                @sorted_procs['before_each'][] = @proc
            } else {
                @len = length(@setting['pref_test_init_proc'])
                if (length(@proc) >= @len && @proc[cslice(0, @len-1)] == @setting['pref_test_init_proc']) {
                    @sorted_procs['before_all'][] = @proc
                } else {
                    @len = length(@setting['pref_test_end_proc'])
                    if (length(@proc) >= @len && @proc[cslice(0, @len-1)] == @setting['pref_test_end_proc']) {
                        @sorted_procs['after_all'][] = @proc
                    } else {
                        @len = length(@setting['pref_after_proc'])
                        if (length(@proc) >= @len && @proc[cslice(0, @len-1)] == @setting['pref_after_proc']) {
                            @sorted_procs['after_each'][] = @proc
                        }
                    }
                }
            }
        }
    }
    return(@sorted_procs)
}

proc _private_unit_tester_log_result(@setting, @result, @time, @outs) {
    foreach(@out in @outs) {
        int @count_tests = 0
        int @count_failures = 0
        int @count_skipped = 0
        if (!@out['enable'], continue())
        @builder = res_create_resource('STRING_BUILDER')
        string_append(@builder, '\n[TIME] ')
        string_append(@builder, '['.@setting['name_module'].'] ')
        string_append(@builder,  simple_date('yyyy.MM.dd \'at\' HH:mm:ss'))
        string_append(@builder, '\n')
        if (@out['short'] == true) {
            foreach(@script: @tests in @result) {
                int @lcount_tests = 0
                int @lcount_failures = 0
                int @lcount_skipped = 0
                string_append(@builder, '\n\n###########################################################\n')
                string_append(@builder, 'Script: ')
                string_append(@builder, @script)
                string_append(@builder, '\n')
                foreach(@test: @info in @tests) {
                    @count_tests++
                    @lcount_tests++
                    string_append(@builder, '\n-----------------------------------------------------------\n')
                    if (@info['skipped']) {
                        @count_skipped++
                        @lcount_skipped++
                        string_append(@builder, '# ')
                        string_append(@builder, 'Test: ')
                        string_append(@builder, @test)
                        string_append(@builder, ' - skipped\n')
                        continue()
                    } else if (@info['successful']) {
                        string_append(@builder, '+ ')
                    } else {
                        @count_failures++
                        @lcount_failures++
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
                string_append(@builder, '\n***********************************************************\n')
                string_append(@builder, "Tests run: @count_tests, Failures: @count_failures, Skipped: @count_skipped\n")   
            }
            string_append(@builder, '\n===========================================================\n')
            string_append(@builder, "Global statistics. Time: @time, Tests run: @count_tests, Failures: @count_failures, Skipped: @count_skipped")   
        } else {
            foreach(@script: @tests in @result) {
                string_append(@builder, '\n\n###########################################################\n')
                string_append(@builder, 'Script: ')
                string_append(@builder, @script)
                string_append(@builder, '\n')
                int @lcount_tests = 0
                int @lcount_failures = 0
                int @lcount_skipped = 0
                foreach(@test: @info in @tests) {
                    @count_tests++
                    @lcount_tests++
                    string_append(@builder, '\n-----------------------------------------------------------\n')
                    if (@info['skipped']) {
                        @count_skipped++
                        @lcount_skipped++
                        string_append(@builder, '# ')
                        string_append(@builder, 'Test: ')
                        string_append(@builder, @test)
                        string_append(@builder, ' - skipped\n')
                        continue()
                    } else if (@info['successful']) {
                        string_append(@builder, '+ ')
                    } else {
                        @count_failures++
                        @lcount_failures++
                        string_append(@builder, '- ')
                    }
                    string_append(@builder, 'Test: ')
                    string_append(@builder, @test)
                    string_append(@builder, sprintf(' - status: %s, time %f.\n', @info['successful'], @info['time']))
                    if (@info['user_message'] != null) {
                        string_append(@builder, 'Message: ')
                        string_append(@builder, string(@info['user_message']))
                        string_append(@builder, '\n')
                    }
                    @user_log = string(@info['user_log'])
                    if (@user_log != '') {
                        string_append(@builder, '\n')
                        string_append(@builder, @user_log)
                        string_append(@builder, '\n')
                    }
                    if (!@info['successful']) {
                        string_append(@builder, @info['test_log'])
                        string_append(@builder, '\n')  
                    }
                }
                string_append(@builder, '\n***********************************************************\n')
                string_append(@builder, "Tests run: @lcount_tests, Failures: @lcount_failures, Skipped: @lcount_skipped\n")   
            }
            string_append(@builder, '\n===========================================================\n')
            string_append(@builder, "Global statistics. Time: @time, Tests run: @count_tests, Failures: @count_failures, Skipped: @count_skipped")   
        }
        string_append(@builder, '\n')
        execute(string(@builder), @out['write'])
    }
}
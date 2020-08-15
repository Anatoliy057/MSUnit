proc _package_unit_tester(@tests, @module, @setting, @outs) {
    include('synchron.ms')
    include('environment.ms')
    @task_ex = _util_tasker_init_self('org.cadabra.msunit.tester-takser', @setting['number_threads'], 1, false)
    @result = _unit_env_global_get()
    @count_tests = 0
    export('org.cadabra.msunit.tester.count', 0)

    _unit_resource_init(@module['resource'])
    _util_make_file(@module['localPackages'], -2)
    try {
        include(@module['localPackages'])
    } catch(Error @e) {
        console('[MSUNIT] Exception when connecting local scripts. Termination of tests.', false)
        console(_util_parse_exception(@e))
        return()
    }

    foreach(@test in @tests) {
        @count_tests += _private_unit_tester_add_test(@test, @module['tests'], @setting, @result, @task_ex)
    }
    @size = _util_tasker_size_waiting(@task_ex)
    @time = -nano_time()
    _util_tasker_start(@task_ex)
    @cur = 0
    console('0 %', false)
    while(_util_tasker_complited(@task_ex) != @size) {
        if ((@n = import('org.cadabra.msunit.tester.count')) != @cur) {
            @cur = @n
            int @percent = integer((@n/@count_tests)*100)
            console("@percent %", false)
        }
    }
    _util_tasker_stop(@task_ex)
    @time += nano_time()
    @time /= 1000000000
    _private_unit_tester_log_result(@setting, @result, @time, @outs)
}

int proc _private_unit_tester_add_test(string @test, string @path_to_test, array @setting, array @result, array @task_ex) {
    @path = @path_to_test._util_sdn().replace(@test, '.', _util_sdn()).'.ms'
    @procs = array()
    if (file_exists(@path)) {
        @old_procs = get_procedures()
        include(@path)
        @new_procs = get_procedures()
        @procs = _util_array_minus(@new_procs, @old_procs)
    } else {
        console(_package_unit_msg_module_log('script_not_found', @test), false)
        return(0)
    }
    @sorted_procs = _private_unit_tester_sep_procs(@test, @procs, @setting)
    if (@sorted_procs == null) {
        return(0)
    }
    @task = _private_unit_tester_init_task(@test, @sorted_procs, @setting, @result)
    _util_tasker_add(@task_ex, @task)
    return(array_size(@sorted_procs['tests']))
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

        @res = associative_array()
        @res['time'] = -nano_time() 
        try {
            @before_all = call_proc(@lymda_before_all)
        } catch (Exception @e) {
            @exception = array()
            _unit_env_init_cur(@res, @setting)
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
            @result[@test]['_before_all'] = @res
        } finally {
            @res['time'] += nano_time() 
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
                    @before_each = call_proc(@lymda_before_each, @proc_test)
                    @args = array()
                    if (@before_all) {
                        @args[] = @before_all
                    }
                    if (@before_each) {
                        @args[] = @before_each
                    }
                    if (@lymda_after_each == '_package_unit_undef_proc') {
                        call_proc_array(@proc_test, @args)
                    } else {
                        @return = call_proc_array(@proc_test, @args)
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
            while (x_thread_is_alive(@name_thread)) {
                x_thread_join(@name_thread)
            }
            _util_clear_interval(@id_interval)
            _private_unit_tester_count_plus()
        }
        @res = associative_array()
        try {
            @res['time'] = -nano_time()
            call_proc(@lymda_after_all)
        } catch (Exception @e) {
            @exception = array()
            _unit_env_init_cur(@res, @setting)
            @exception['classType'] = @e['classType']
            @exception['message'] = @e['message']
            @exception['stackTrace'] = @e['stackTrace'][..-2]
            @res['successful'] = false
            @res['test_log'] = _package_unit_log_unex_throw(@exception)
            @result[@test]['_after_all'] = @res
        } finally {
            @res['time'] += nano_time()
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

proc _private_unit_tester_count_plus() {
    //synchronized('org.cadabra.msunit.tester.count') {
        export('org.cadabra.msunit.tester.count', import('org.cadabra.msunit.tester.count') + 1)
    //}
}

proc _private_unit_tester_log_result(@setting, @result, @time, @outs) {
    foreach(@out in @outs) {
        int @count_tests = 0
        int @count_failures = 0
        int @count_skipped = 0
        @builder = res_create_resource('STRING_BUILDER')
        string_append(@builder, '\n[TIME] ')
        string_append(@builder, '['.@setting['name_module'].'] ')
        string_append(@builder,  simple_date('yyyy.MM.dd \'at\' HH:mm:ss'))
        string_append(@builder, '\n')
        foreach(@script: @tests in @result) {
            string_append(@builder, color(@setting['colors']['script']))
            string_append(@builder, '\n\n###########################################################\n')
            string_append(@builder, 'Script: ')
            string_append(@builder, color('UNDERLINE'))
            string_append(@builder, @script)
            string_append(@builder, color('PLAIN_WHITE'))
            string_append(@builder, '\n')
            string_append(@builder, color(@setting['colors']['default']))
            int @lcount_tests = 0
            int @lcount_failures = 0
            int @lcount_skipped = 0
            foreach(@test: @info in @tests) {
                @count_tests++
                @lcount_tests++
                string_append(@builder, color(@setting['colors']['test']))
                string_append(@builder, '\n-----------------------------------------------------------\n')
                if (@info['skipped']) {
                    @count_skipped++
                    @lcount_skipped++
                    string_append(@builder, color(@setting['colors']['test_skip']))
                    string_append(@builder, '### ')
                    string_append(@builder, color(@setting['colors']['default']))
                    string_append(@builder, 'Test: ')
                    string_append(@builder, color('ITALIC'))
                    string_append(@builder, color(@setting['colors']['test']))
                    string_append(@builder, @test)
                    string_append(@builder, color('PLAIN_WHITE'))
                    string_append(@builder, color(@setting['colors']['default']))
                    string_append(@builder, ' - skipped\n')
                    continue()
                } else if (@info['successful']) {
                    string_append(@builder, color(@setting['colors']['test_successful']))
                    string_append(@builder, '+++ ')
                    string_append(@builder, color(@setting['colors']['default']))
                } else {
                    @count_failures++
                    @lcount_failures++
                    string_append(@builder, color(@setting['colors']['test_fail']))
                    string_append(@builder, '--- ')
                    string_append(@builder, color(@setting['colors']['default']))
                }
                string_append(@builder, 'Test: ')
                string_append(@builder, color('ITALIC'))
                string_append(@builder, color(@setting['colors']['test']))
                string_append(@builder, @test)
                string_append(@builder, color('PLAIN_WHITE'))
                string_append(@builder, color(@setting['colors']['default']))
                string_append(@builder, ', time: ')
                if (@info['limit_time']['successful'] >= @info['time']) {
                    string_append(@builder, color(@setting['colors']['time_successful']))
                } else if (@info['limit_time']['attention'] >= @info['time']) {
                    string_append(@builder, color(@setting['colors']['time_attention']))
                } else {
                    string_append(@builder, color(@setting['colors']['time_fail']))
                }
                string_append(@builder, @info['time'])
                string_append(@builder, '\n')
                string_append(@builder, color(@setting['colors']['default']))
                if (@info['message'] != null && array_contains(@out['filters'], 'message')) {
                    string_append(@builder, color(@setting['colors']['message']))
                    string_append(@builder, 'Message: ')
                    string_append(@builder, string(@info['message']))
                    string_append(@builder, '\n')
                    string_append(@builder, color(@setting['colors']['default']))
                }
                if (array_contains(@out['filters'], 'user_log')) {
                    @user_log = string(@info['user_log'])
                    if (@user_log != '') {
                        string_append(@builder, color(@setting['colors']['user_log']))
                        string_append(@builder, '\n')
                        string_append(@builder, @user_log)
                        string_append(@builder, '\n')
                        string_append(@builder, color(@setting['colors']['default']))
                    }
                }
                if (!@info['successful'] && array_contains(@out['filters'], 'test_log')) {
                    string_append(@builder, color(@setting['colors']['test_log']))
                    string_append(@builder, @info['test_log'])
                    string_append(@builder, '\n')
                    string_append(@builder, color(@setting['colors']['default']))
                }
            }
            string_append(@builder, '\n***********************************************************\n')
            _unit_tester_log_color_statistics(@lcount_tests, @lcount_failures, @lcount_skipped, @builder, @setting)  
        }
        string_append(@builder, '\n===========================================================\n')
        string_append(@builder, "Global statistics. Time: @time, ")
        _unit_tester_log_color_statistics(@count_tests, @count_failures, @count_skipped, @builder, @setting)  
        execute(string(@builder), @out['write'])
    }
}

proc _unit_tester_log_color_statistics(int @tests, int @failures, int @skipped, @builder, @setting) {
    if (@tests != 0) {
        string_append(@builder, color(@setting['colors']['test']))
        string_append(@builder, 'Tests run: ')
        string_append(@builder, @tests)
        string_append(@builder, color(@setting['colors']['default']))
    } else {
        string_append(@builder, color(@setting['colors']['test_fail']))
        string_append(@builder, 'Tests run: ')
        string_append(@builder, @tests)
        string_append(@builder, color(@setting['colors']['default']))
    }
    string_append(@builder, ', ')
    if (@failures == 0) {
        string_append(@builder, color(@setting['colors']['test_successful']))
        string_append(@builder, 'Failures: ')
        string_append(@builder, @failures)
        string_append(@builder, color(@setting['colors']['default']))
    } else {
        string_append(@builder, color(@setting['colors']['test_fail']))
        string_append(@builder, 'Failures: ')
        string_append(@builder, @failures)
        string_append(@builder, color(@setting['colors']['default']))
    }
    string_append(@builder, ', ')
    if (@skipped == 0) {
        string_append(@builder, color(@setting['colors']['test']))
        string_append(@builder, 'Skipped: ')
        string_append(@builder, @skipped)
        string_append(@builder, color(@setting['colors']['default']))
    } else {
        string_append(@builder, color(@setting['colors']['test_skip']))
        string_append(@builder, 'Skipped: ')
        string_append(@builder, @skipped)
        string_append(@builder, color(@setting['colors']['default']))
    }
    string_append(@builder, '\n')   
}
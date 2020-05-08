proc _package_unit_runner(@tests, @setting, @out) {

    @map = array()
    foreach(@test in @tests) {
        @path = replace(@test, '.', '/').'.ms'
        if (file_exists(@path)) {
            @old_procs = get_procedures()
            include(@path)
            @new_procs = get_procedures()
            @map[@test] = _util_array_minus(@new_procs, @old_procs)
        } else {
            console(_package_unit_msg_module_log('script_not_found', @test))
            continue()
        }
    }
    @model = _private_unit_runner_init_model(@map, @setting)
    @result = _unit_env_global_get()
    @tasks = _private_unit_runner_init_tasks(@model, @setting, @result)
    @task_ex = _util_task_ex_init_self('__unit_thread_starting_tests', @setting['number_threads'], 1, false)
    foreach(@task in @tasks) {
        _util_task_ex_add(@task_ex, @task)
    }
    _util_task_ex_start(@task_ex)
    while(_util_task_ex_complited(@task_ex) != array_size(@tasks)) {}
    _util_task_ex_stop(@task_ex)
    _private_unit_runner_log_result(@result, @out)
}

proc _private_unit_runner_sort_procs(@procs, @setting) {
    @sorted_procs = array()
    @sorted_procs['tests'] = array()
    @sorted_procs['before_each'] = array()
    @sorted_procs['before_all'] = array()
    foreach(@proc in @procs) {
        @len = length(@setting['pref_test_proc'])
        if (@proc[cslice(0, @len-1)] == @setting['pref_test_proc']) {
            array_push(@sorted_procs['tests'], @proc)
        } else {
            @len = length(@setting['pref_before_proc'])
            if (@proc[cslice(0, @len-1)] == @setting['pref_before_proc']) {
                array_push(@sorted_procs['before_each'], @proc)
            } else {
                @len = length(@setting['pref_test_init_proc'])
                if (@proc[cslice(0, @len-1)] == @setting['pref_test_init_proc']) {
                    array_push(@sorted_procs['before_all'], @proc)
                }
            }
        }
    }
    return(@sorted_procs)
}

proc _private_unit_runner_init_model(@map, @setting) {
    @model = array()
    foreach(@script: @procs in @map) {
        @sorted_procs = _private_unit_runner_sort_procs(@procs, @setting)

        if (array_size(@sorted_procs['before_each']) > 1) {
            console(_package_unit_msg_module_log('collision_proc_before_each', @script, @setting['pref_before_proc'], @sorted_procs['before_each']))
            continue()
        } else if (array_size(@sorted_procs['before_all']) > 1) {
            console(_package_unit_msg_module_log('collision_proc_before_all', @script, @setting['pref_test_init_proc'], @sorted_procs['before_all']))
            continue()
        } else if (array_size(@sorted_procs['tests']) == 0) {
            console(_package_unit_msg_module_log('procs_test_not_found', @setting['pref_test_proc'], @script))
            continue()
        }

        @model[@script]['procs'] = @sorted_procs
    }
    return(@model)
}

proc _private_unit_runner_init_tasks(@model, @setting, @result) {
    @tasks = array()
    foreach(@script_name: @info in @model) {
        # @script_name is name of script
        # @val is info of test
        @result[@script_name] = array()
        @runnable = closure() {
            @lymda_before
            @lymda_each
            @tests = @info['procs']['tests']
        
            if (@info['procs']['before_all'] == null || array_size(@info['procs']['before_all']) == 0) {
                @lymda_before = '_package_unit_undef_proc'
            } else {
                @lymda_before = @info['procs']['before_all'][0]
            }
            if (@info['procs']['before_each'] == null || array_size(@info['procs']['before_each']) == 0) {
                @lymda_each = '_package_unit_undef_proc'
            } else {
                @lymda_each = @info['procs']['before_each'][0]
            }

            @before_all = call_proc(@lymda_before)
            for(@i = 0, @i < array_size(@tests), @i ++) {
                @proc_test = @tests[@i]
                @before_each = call_proc(@lymda_each)

                @result[@script_name][@proc_test] = array()
                @res = @result[@script_name][@proc_test]
                _unit_env_init_cur(@res, @setting)
                
                @name_thread = @script_name.':'.@proc_test
                @motitor = _package_unit_syn_set(@name_thread)
                @name_thread = _package_unit_static_to_unit_thread(@name_thread)

                x_new_tracked_thread(@name_thread, closure() {
                    @res['time'] = -nano_time()
                    try {
                        call_proc(@proc_test, @before_all, @before_each)
                    } catch(Exception @e) {
                        @res['successful'] = false
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
        array_push(@tasks, @runnable)
    }
    return(@tasks)
}

proc _private_unit_runner_log_result(@result, @outs) {
    foreach(@out in @outs) {
        if (!@out['enable'], continue())
        @builder = res_create_resource('STRING_BUILDER')
        string_append(@builder, '[TIME] 'simple_date('yyyy.MM.dd G \'at\' HH:mm:ss z'))
        string_append(@builder, '\n')
        if (@out['short'] == true) {
            foreach(@script: @tests in @result) {
                string_append(@builder, 'Script: ')
                string_append(@builder, @script)
                string_append(@builder, '\n')
                foreach(@test: @info in @tests) {
                    string_append(@builder, '\tTest: ')
                    string_append(@builder, @test)
                    string_append(@builder, sprintf(' - status: %s, time %f.\n', @info['successful'], @info['time']))
                }
            }
        } else {
            foreach(@script: @tests in @result) {
                string_append(@builder, 'Script: ')
                string_append(@builder, @script)
                string_append(@builder, '\n')
                foreach(@test: @info in @tests) {
                    string_append(@builder, '\tTest: ')
                    string_append(@builder, @test)
                    string_append(@builder, sprintf(' - status: %s, time %f.\n', @info['successful'], @info['time']))
                    if (!@info['successful']) {
                        string_append(@builder, @info['test_log'])
                        string_append(@builder, '\n')
                    }
                    string_append(@builder, string(@info['user_log']))     
                }
            }
        }
        execute(string(@builder), @out['write'])
    }
}
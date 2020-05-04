proc _package_unit_do_tests(@tests, @setting, @out) {

    @map = array()
    foreach(@test in @tests) {
        @path = replace(@test, '.', '/').'.ms'
        if (file_exists(@path)) {
            @old_procs = get_procedures()
            include(@path)
            @new_procs = get_procedures()
            @map[@test] = _util_array_minus(@new_procs, @old_procs)
        } else {
            console(_package_unit_get_msg('script_not_found', @test))
            continue()
        }
    }
    @model = _private_unit_init_model(@map, @setting)
    @result = _package_unit_get_log()
    @tasks = _private_unit_init_tasks(@model, @setting, @result)
    @task_ex = _util_task_ex_init_self('__unit_thread_starting_tests', @setting['number_threads'], 1, false)
    foreach(@task in @tasks) {
        _util_task_ex_add(@task_ex, @task)
    }
    _util_task_ex_start(@task_ex)
    while(_util_task_ex_complited(@task_ex) != array_size(@tasks)) {}
    _util_task_ex_stop(@task_ex)
    _private_unit_log_result(@result, @out)
}

proc _private_unit_sort_procs(@procs, @setting) {
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

proc _private_unit_init_model(@map, @setting) {
    @model = array()
    foreach(@script: @procs in @map) {
        @sorted_procs = _private_unit_sort_procs(@procs, @setting)

        if (array_size(@sorted_procs['before_each']) > 1) {
            console(_package_unit_get_msg('collision_proc_before_each', @script, @setting['pref_test_proc'], @sorted_procs['before_each']))
            continue()
        } else if (array_size(@sorted_procs['before_all']) > 1) {
            console(_package_unit_get_msg('collision_proc_before_all', @script, @setting['pref_before_proc'], @sorted_procs['before_all']))
            continue()
        } else if (array_size(@sorted_procs['tests']) == 0) {
            console(_package_unit_get_msg('procs_test_not_found', @setting['pref_test_init_proc'], @script))
            continue()
        }

        @model[@script]['procs'] = @sorted_procs
    }
    return(@model)
}

proc _private_unit_init_tasks(@model, @setting, @result) {
    @tasks = array()
    foreach(@script_name: @val in @model) {
        # @script_name is name script
        # @val is info of test
        @result[@script_name] = array()
        @runnable = closure() {
            @lymda_before = @val['procs']['before_all'][0]
            @lymda_each = @val['procs']['before_each'][0]
            @tests = @val['procs']['tests']
        
            if (@lymda_before == null) {
                @lymda_before = closure() {return('Doesn\'t init')}
            }
            if (@lymda_each == null) {
                @lymda_each = closure() {return('Doesn\'t init')}
            }

            @before_all = call_proc(@lymda_before)
            for(@i = 0, @i < array_size(@tests), @i ++) {
                @proc_test = @tests[@i]
                @before_each = call_proc(@lymda_each)

                @result[@script_name][@proc_test] = array()
                @res = @result[@script_name][@proc_test]
                @res['successful'] = true
                @res['log'] = array()
                @res['assert_timeout'] = @setting['assert_timeout']
                @res['proc_timeout'] = @setting['proc_timeout']

                @name_thread = @script_name.':'.@proc_test
                x_new_tracked_thread(@name_thread, closure() {
                    @res['time'] = -nano_time()
                    try {
                        call_proc(@proc_test, @before_all, @before_each)
                    } catch(Exception @e) {
                        @res['successful'] = false
                        console(@e)
                        //todo log
                    } finally {
                        @res['time'] += nano_time()
                    }
                })
                _package_unit_set_syn_o(@script_name)
                @id_interval = _util_interval(1, 0, closure() {
                    synchronized(_package_unit_get_syn_timer(@script_name)) {
                        @res['assert_timeout'] -= 1
                        @res['proc_timeout'] -= 1
                    }
                })
                while (tracked_thread_is_alive(@name_thread)) {
                    if (@res['assert_timeout'] <= 0 && tracked_thread_is_alive(@name_thread)) {
                        x_stop_tracked_thread(@name_thread)
                        //todo log
                        break()
                    }
                    if (@res['proc_timeout'] <= 0  && tracked_thread_is_alive(@name_thread)) {
                        x_stop_tracked_thread(@name_thread)
                        //todo log
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

proc _private_unit_log_result(@result, @out) {
    foreach(@key: @value in @result) {
        console(@result)
    }
}
proc _package_unit_do_tests(@tests, @setting, @out) {
    @get_procs = closure(@path) {
        @old_procs = get_procedures()
        include(@path)
        @new_procs = get_procedures()
        return(_util_array_minus(@new_procs, @old_procs))
    }

    @model = array()
    foreach(@test in @tests) {
        @path = replace(@test, '.', '/').'.ms'
        if (!file_exists(@path)) {
            console('Test: '.@path.' don\'t found')
            continue()
        }
        @procs = execute(@path, @get_procs)
        @sorted_procs = _private_unit_sort_procs(@procs, @setting)

        if (array_size(@sorted_procs['before_each']) > 1) {
            console(
                'CHUnit: [ERROR] syntax error in script: '.@test.'\n'
                '\t\t\t\tMethod '.@setting['pref_before_proc'].'* should be the only one\n'.
                '\t\t\t\tFound functions: '.@sorted_procs['before_each']'\n'.
                '\t\t\t\tIgnored this script'
            )
            continue()
        } else if (array_size(@sorted_procs['before_all']) > 1) {
            console(
                'CHUnit: [ERROR] syntax error in script: '.@test.'\n'.
                '\t\t\t\tMethod '.@setting['pref_test_init_proc'].'* should be the only one\n'.
                '\t\t\t\tFound functions: '.@sorted_procs['before_all'].'\n'.
                '\t\t\t\tIgnored this script'
            )
            continue()
        } else if (array_size(@sorted_procs['tests']) == 0) {
            console(
                'CHUnit: [WARNING] not found tests in script: '.@test.'\n'.
                '\t\t\t\tIgnored this script'
            )
            continue()
        }

        @model[@test]['procs'] = @sorted_procs
        @model[@test]['assert_timeout'] = 30
        @model[@test]['proc_timeout'] = 120
        @model[@test]['live'] = true
    }

    console(@model)
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
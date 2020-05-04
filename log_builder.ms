proc _package_unit_log_init_self() {
    @self = array()
    @self['trace'] = null
    @self['cause'] = null
    @self['result'] = null
    return(@self)
}

proc _package_unit_log_set_cause(@self, @cause) {
    @self['cause'] = @cause
}

proc _package_unit_log_set_trace(@self, @trace) {
    @self['trace'] = @trace
}

proc _package_unit_log_set_diff(@self, @expect, @actually) {
    @self['result'] = _package_unit_get_clear_msg('template_diff', @expect, @actually)
}

proc _package_unit_log_set_single(@self, @result) {
    @self['result'] = _package_unit_get_clear_msg('template_result', @result)
}

proc _package_unit_log_build(@self) {
    @builder = res_create_resource('STRING_BUILDER')

    string_append(@builder, @self['cause'])
    string_append(@builder, '\n')

    if (@self['result'] != null) {
        string_append(@builder, @self['result'])
        string_append(@builder, '\n')
    }

    if (@self['trace'] != null) {
        string_append(@builder, @self['trace'])
    }

    return(string(@builder))
}

proc _package_unit_log_assert_timeout() {
    return(_package_unit_get_clear_msg('cause_timeout_assert'))
}

proc _package_unit_log_proc_timeout() {
    return(_package_unit_get_clear_msg('cause_timeout_proc'))
}

proc _package_unit_log_unex_throw(@e) {
    @self = _package_unit_log_init_self()
    _package_unit_log_set_cause(@self, _package_unit_get_clear_msg('cause_unexpected_throw', @e['classType']))
    _package_unit_log_set_single(@self, @e)
    return(_package_unit_log_build(@self))
}
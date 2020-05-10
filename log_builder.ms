proc _unit_log_open_tab(@self) {
    @self['private_tab'] .= '\t'
}

proc _unit_log_close_tab(@self) {
    int @l = length(@self['private_tab'])
    if (@l < 1) {
        return()
    }
    @self['private_tab'] = @self['private_tab'][cslice(0, @l-2)]
}

proc _unit_log_set_msg(@self, @private_msg) {
    @self['private_msg'] = @self['private_tab'].@private_msg
}

proc _unit_log_set_diff(@self, @vals) {
    @self['private_msg'] = @self['private_tab']._package_unit_msg_test_log('msg', 'diff', @vals[0], @vals[1])
}

proc _unit_log_set_result(@self, @res) {
    @self['private_msg'] = @self['private_tab']._package_unit_msg_test_log('msg', 'result', @res)
}

proc _unit_log_set_type_msg(@self, @type, @vals) {
    @self['private_msg'] = @self['private_tab']._package_unit_msg_test_log_with_args('msg', @type, @vals)
}

proc _unit_log_set_trace(@self, @private_traces) {
    @builder = res_create_resource('STRING_BUILDER')
    @size = array_size(@private_traces)
    for(@i = 0, @i < @size, @i++) {
        @private_trace = @private_traces[@i]
        string_append(@builder, @self['private_tab'])
        string_append(@builder, 'at ')
        string_append(@builder, @private_trace['id'])
        string_append(@builder, ':')
        string_append(@builder, @private_trace['file'])
        string_append(@builder, ':')
        string_append(@builder, @private_trace['line'])
        string_append(@builder, '.')
        string_append(@builder, @private_trace['col'])
        if (@i + 1 != @size) {
            string_append(@builder, '\n')
        }
    }
    @self['private_trace'] = string(@builder)
}

proc _unit_log_set_def_cause(@self, @type) {
    @self['private_cause'] = @self['private_tab']._package_unit_msg_test_log('cause', @type)
}

proc _unit_log_set_cause(@self, @private_cause) {
    @self['private_cause'] = @self['private_tab'].@private_cause
}

proc _unit_log_build(@self) {
    @builder = res_create_resource('STRING_BUILDER')

    boolean @last = false
    if (@self['private_cause'] != null) {
        string_append(@builder, @self['private_cause'])
        @last = true
    }

    if (@self['private_msg'] != null) {
        if (@last) {
            string_append(@builder, '\n')
        }
        string_append(@builder, @self['private_msg'])   
    }

    if (@self['private_trace'] != null) {
        if (@last) {
            string_append(@builder, '\n')
        }
        string_append(@builder, @self['private_trace'])
    }

    return(string(@builder))
}

proc _unit_log_set(@self) {
    @size = array_size(@arguments)
    if (@size < 2 || (@size-1) % 2 != 0) {
        return()
    }
    for(@i = 1, @i < @size, @i+=2) {
        @key = @arguments[@i]
        @vals = @arguments[@i+1]
        call_proc('_unit_log_'.@key, @self, @vals)
    }
}

proc _unit_log_init_self() {
    @self = array()

    @self['private_trace'] = null
    @self['private_cause'] = null
    @self['private_msg'] = null
    @self['private_tab'] = ''

    return(@self)
}

proc _package_unit_log_proc_timeout() {
    @self = _unit_log_init_self()
    _unit_log_set(@self,
        'set_cause', _package_unit_msg_test_log('cause', 'timeout_proc')
    )
    return(_unit_log_build(@self))
}

proc _package_unit_log_assert_timeout() {
     @self = _unit_log_init_self()
    _unit_log_set(@self,
        'set_cause', _package_unit_msg_test_log('cause', 'timeout_assert')
    )
    return(_unit_log_build(@self))
}

proc _package_unit_log_unex_throw(@e) {
    @self = _unit_log_init_self()
    _unit_log_set(@self,
        'set_cause', _package_unit_msg_test_log('cause', 'unexpected_ex'),
        'set_msg',  @e['classType'].': '.@e['message'],
        'set_trace', @e['stackTrace']
    )
    return(_unit_log_build(@self))
}
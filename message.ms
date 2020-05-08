proc _package_unit_msg_module_log(string @key) {
    @model = import('__unit_msg')
    @template = @model['prefix'].@model['module_log'][@key]
    if (array_size(@arguments) < 2) {
        return(@template)
    } else {
        return(sprintf(@template, @arguments[1..]))
    }
}

proc _package_unit_msg_test_log(string @type, string @key) {
    @model = import('__unit_msg')
    @template = @model['test_log'][@type][@key]
    if (array_size(@arguments) < 3) {
        return(@template)
    } else {
        return(sprintf(@template, @arguments[2..]))
    }
}
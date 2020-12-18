proc _msunit_get_class(string @className, int @stackTrace = 1) {
    @root = _msunit_import_root()

    @classes = import('ms.org.cadabra.unit.util.class')

    if (_key_in(@classes, @className)) {
        return(@classes['className'])
    } else {
        @class = array_implode(
            reg_split(
                '[\\\\/]',
                substr(
                    get_stack_trace()[@stackTrace]['file'][-4..],
                    length(@root)
                )[..-2],
            ),
            '.'
        )

        @classes[@className] = @class

        return(@class)
    }
}

proc _msunit_register_class(string @className, array @attributes, int @stackTrace = 2) {
    string @class = _msunit_get_class(@class, @stackTrace)

    @attributes['class'] = @class
    @attributes['className'] = @className

    export(@class, @attributes)
}

proc _msunit_static_method(string @method, string @class) {
    @object = _msunit_import_class(@class)
    @arguments[1] = @object
    return(_method_array(@arguments))
}

proc _msunit_import_class(string @className) {
    import(_msunit_get_class(@className))
}

_msunit_include_add(closure() {
    export('ms.org.cadabra.unit.util.class', associative_array())
})
proc _msunit_get_class(string @className) {
    @root = _msunit_import_root()
    @classes = original_import('org.cadabra.msunit.util.class')

    if (array_index_exists(@classes, @className)) {
        return(@classes[@className])
    
    } else {
        throw(IllegalArgumentException, "That class @className is not registered")
    }
}

proc _msunit_register_class(string @className, array @attributes) {
    @classes = original_import('org.cadabra.msunit.util.class')

    @attributes['__class__'] = @className

    @classes[@className] = @attributes
}

proc _msunit_static_method(string @method, string @class) {
    @object = _msunit_get_class(@class)
    @arguments[1] = @object
    return(_method_array(@arguments))
}

execute(closure() {
    export('org.cadabra.msunit.util.class', associative_array())
})

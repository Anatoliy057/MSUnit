proc _msunit_get_class(string @className) {
    @root = _msunit_import_root()
    @classes = import('org.cadabra.msunit.util.class')

    if (array_index_exists(@classes, @className)) {
        return(@classes[@className])
    
    } else {
        throw(IllegalArgumentException, "That class @className is not registered")
    }
}

proc _msunit_register_class(string @className, array @attributes, array @methods) {
    @classes = import('org.cadabra.msunit.util.class')
    @attributes['__class__'] = @className

    foreach(@key: @procName in @methods) {
        @attributes[@key] = to_func(@procName)
    }

    @classes[@className] = @attributes
}

execute(closure() {
    export('org.cadabra.msunit.util.class', associative_array())
    export('org.cadabra.msunit.__include__', array())
})


void proc _msunit_include_add(closure @include) {
    import('org.cadabra.msunit.__include__')[] = @include
}

include_dir('src/main', true)

foreach(@include in import('org.cadabra.msunit.__include__')) {
    @include()
}

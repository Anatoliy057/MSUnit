void proc _msunit_include_add(closure @include) {
    import('org.cadabra.msunit.__include__')[] = @include
}

void proc _msunit_include_all() {
    foreach(@include in import('org.cadabra.msunit.__include__')) {
        set_current_env(@include)
        @include()
    }
}

export('org.cadabra.msunit.__include__', array())

include_dir('src/main', true)

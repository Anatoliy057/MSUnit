void proc _msunit_include_add(closure @include) {
    import('org.cadabra.msunit.__include__')[] = @include
}

void proc _msunit_include_all() {
    foreach(@include in import('org.cadabra.msunit.__include__')) {
        execute(@include)
    }
}

include_dir('src/main')

_msunit_include_all()

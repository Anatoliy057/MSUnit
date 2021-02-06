include('__procedures__.ms')
include('__settings__.ms')
include('__include__.ms')

proc _init_msunit() {
    _msunit_include_all()
    
    @app = _msunit_get_application()
    _method('start', @app)

    _msunit_register_module(array(
        id: 'msunit',
        root: file_resolve('src/test'),
    ))
}


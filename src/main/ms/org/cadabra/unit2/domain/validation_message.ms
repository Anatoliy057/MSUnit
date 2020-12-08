array proc _msunit_get_validation_message() {
    import(_msunit_get_class('ValidationMessage'))
}

_msunit_include_add(closure() {
    array @messager = associative_array()

    @messager['warn'] = closure(@m, @self, string @message) {
        return(array(
            status: 'warn',
            message: @message
        ))
    }

    @messager['error'] = closure(@m, @self, string @message) {
        return(array(
            status: 'error',
            message: @message
        ))
    }

    @messager['fatal'] = closure(@m, @self, string @message) {
        return(array(
            status: 'fatal',
            message: @message
        ))
    }

    @messager['success'] = closure(@m, @self) {
        return(array(
            status: 'success'
        ))
    }

    _msunit_register_class('ValidationMessage', @messager)
})
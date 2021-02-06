array proc _msunit_get_validation_messager() {
    return(_msunit_get_class('ValidationMessage'))
}

_msunit_include_add(closure() {
    array @messager = associative_array()

    @messager['getStatusCode'] = closure(@m, @self, string @status) {
        return(switch(
            @status,
            'success', 100,
            'warn', 200,
            'error', 300,
            'fatal', 500,
            -1
        ))
    }

    @messager['getColorStatus'] = closure(@m, @self, string @status) {
        return(switch(@status,
            'success', color('GREEN'),
            'warn', color('YELLOW'),
            'error', color('DARK_RED'),
            'fatal', color('DARK_RED'),
            color('AQUA')
        ))
    }

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

    @messager['format'] = closure(@m, @self, array @msgObject) {
        @status = to_upper(@msgObject['status'])
        @message = @msgObject['message']
        @c = _method('getColorStatus', @self, @msgObject['status'])
        @cg = color('GRAY')

        return("@c[@status]@cg @message")
    }

    _msunit_register_class('ValidationMessage', @messager)
})
array proc _msunit_get_validation_messager() {
    return(_msunit_get_class('ValidationMessage'))
}

_msunit_include_add(closure() {
    array @messager = associative_array()

    proc _getStatusCode(@self, string @status) {
        return(switch(
            @status,
            'success', 100,
            'warn', 200,
            'error', 300,
            'fatal', 500,
            -1
        ))
    }

    proc _getColorStatus(@self, string @status) {
        return(switch(@status,
            'success', color('GREEN'),
            'warn', color('YELLOW'),
            'error', color('DARK_RED'),
            'fatal', color('DARK_RED'),
            color('AQUA')
        ))
    }

    proc _warn(@self, string @message) {
        return(array(
            status: 'warn',
            message: @message
        ))
    }

    proc _error(@self, string @message) {
        return(array(
            status: 'error',
            message: @message
        ))
    }

    proc _fatal(@self, string @message) {
        return(array(
            status: 'fatal',
            message: @message
        ))
    }

    proc _success(@self) {
        return(array(
            status: 'success'
        ))
    }

    proc _format(@self, array @msgObject, string @id = null) {
        @status = to_upper(@msgObject['status'])
        @message = @msgObject['message']
        @c = _method('getColorStatus', @self, @msgObject['status'])
        @cg = color('GRAY')
        
        if(@id == null) {
            return("@c[MSUnit/@status]@cg @message")
        
        } else {
            return("@c[MSUnit @id/@status]@cg @message")
        }
    }

    _msunit_register_class('ValidationMessage', @messager, array(
        'getStatusCode': '_getStatusCode',
        'getColorStatus': '_getColorStatus',
        'warn': '_warn',
        'error': '_error',
        'fatal': '_fatal',
        'success': '_success',
        'format': '_format',
    ))
})

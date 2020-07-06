proc _test_null_0() {
    _assert_null(import('null'))
    _print('SUCCESSFUL')
}

proc _test_null_1() {
    _assert_null(array(), 'SUCCESSFUL')
}

proc _test_not_null_0() {
    _assert_not_null(array())
    _print('SUCCESSFUL')
}

proc _test_not_null_1() {
    _assert_not_null(null, 'SUCCESSFUL')
}
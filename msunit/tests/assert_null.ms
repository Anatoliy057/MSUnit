proc _unit_before_all_some_text4() {
    //code...
    return('hello')
}

proc _unit_before_each_some_text4() {
    //code...
    return('test')
}

proc _unit_test_null_0() {
    _print('SUCCESSFUL')
    _assert_null(import('null'))
}

proc _unit_test_null_1() {
    _assert_null(array(), 'SUCCESSFUL')
}

proc _unit_test_not_null_0() {
    _print('SUCCESSFUL')
    _assert_not_null(array())
}

proc _unit_test_not_null_1() {
    _assert_not_null(null, 'SUCCESSFUL')
}
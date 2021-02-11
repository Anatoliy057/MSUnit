proc _test_assertType_successfully() {
    _assert_type(array, array(1, 2, 7))
}

proc _test_assertType_fail() {
    _assert_type(array, 7, 'SUCCESSFUL')
}

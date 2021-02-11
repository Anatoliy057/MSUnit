proc _test_assertNull_successfully() {
    _assert_null(null)
}

proc _test_assertNull_fail() {
    _assert_null(array(), 'SUCCESSFUL')
}

proc _test_assertNotNull_successfully() {
    _assert_not_null(array())
}

proc _test_assertNotNull_fail() {
    _assert_not_null(null, 'SUCCESSFUL')
}

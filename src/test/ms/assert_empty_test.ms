proc _test_assertEmpty_assertEmptyArray_successfully() {
    _assert_empty(array())
}

proc _test_assertEmpty_assertNull_fail() {
    _assert_empty(null, 'SUCCESSFUL')
}

proc _test_assertEmpty_assertNotEmptyArray_fail() {
    _assert_empty(array('1' : 1), 'SUCCESSFUL')
}

proc _test_assertNotEmpty_successfully() {
    _assert_not_empty(array(1))
    _assert_not_empty('123')
    _assert_not_empty(null)
}

proc _test_assertNotEmpty_assertEmptyArray_fail() {
    _assert_not_empty(array(), 'SUCCESSFUL')
}

proc _test_assertNotEmpty_assertEmptyString_fail() {
    _assert_not_empty('', 'SUCCESSFUL')
}

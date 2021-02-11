proc _test_assertEquals_successfully() {
    _assert_equals(array(1, 2, 3), array(1, 2, 3))
}

proc _test_assertEquals_fail() {
    _assert_equals(array(1, 2, 3), array(1, 2, 4), 'SUCCESSFUL')
}

proc _test_assertNotEquals_successfully() {
    _assert_not_equals(array(1, 2, 3), array(1, 2, 4))
}

proc _test_assertNotEquals_fail() {
    _assert_not_equals(array(1, 2, 3), array(1, 2, 3), 'SUCCESSFUL')
} 

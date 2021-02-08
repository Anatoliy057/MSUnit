proc _test_assertTrue_successfully() {
    _assert_true(1 == 1)
}

proc _test_assertTrue_fail() {
    _assert_true(1 == 2, 'SUCCESSFUL')
}

proc _test_assertFalse_successfully() {
    _assert_false(1 == 2)
}

proc _test_assertFalse_fail() {
    _assert_false(1 == 1, 'SUCCESSFUL')
}

proc _test_assertSize_successfully() {
    _assert_size(3, array(1, 2, 5))
}

proc _test_assertSize_fail() {
    _assert_size(5, array(), 'SUCCESSFUL')
}

proc _test_assertLength_successfully() {
    _assert_length(3, array(1, 2, 3))
    _assert_length(3, '123')
}

proc _test_assertLength_fail() {
    _assert_length(4, '123', 'SUCCESSFUL')
}

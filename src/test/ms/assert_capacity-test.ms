proc _test_size_0() {
    _assert_size(3, array(1, 2, 5))
}

proc _test_size_1() {
    _assert_size(5, array(), 'SUCCESSFUL')
}

proc _test_len_0() {
    _assert_length(3, array(1, 2, 3))
    _assert_length(3, '123')
}

proc _test_len_1() {
    _assert_length(4, '123', 'SUCCESSFUL')
}

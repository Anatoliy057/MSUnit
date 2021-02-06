proc _test_true_0() {
    _assert_true(1 == 1, 'Wow!')
}

proc _test_true_1() {
    _assert_true(1 == 2, 'SUCCESSFUL')
}

proc _test_false_0() {
    _assert_false(1 == 2)
}

proc _test_false_1() {
    _assert_false(1 == 1, 'SUCCESSFUL')
}

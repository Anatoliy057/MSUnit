proc _test_eq_0() {
    _assert_equals(array(1, 2, 3), array(1, 2, 3))
}

proc _test_eq_1() {
    _assert_equals(array(1, 2, 3), array(1, 2, 4), 'SUCCESSFUL')
}

proc _test_not_eq_0() {
    _assert_not_equals(array(1, 2, 3), array(1, 2, 4))
}

proc _test_not_eq_1() {
    _assert_not_equals(array(1, 2, 3), array(1, 2, 3), 'SUCCESSFUL')
} 

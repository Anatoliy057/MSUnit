proc _test_empty_0() {
    _assert_empty(array())
}

proc _test_empty_1() {
    _assert_empty(null, 'SUCCESSFUL')
}

proc _test_empty_2() {
    _assert_empty(array('1' : 1), 'SUCCESSFUL')
}

proc _test_not_empty_0() {
    _assert_not_empty(array(1))
    _assert_not_empty('123')
    _assert_not_empty(null)
}

proc _test_not_empty_2() {
    _assert_not_empty(array(), 'SUCCESSFUL')
}

proc _test_not_empty_2() {
    _assert_not_empty('', 'SUCCESSFUL')
}

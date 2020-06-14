proc _unit_before_all_some_text6() {
    //code...
    return('hello')
}

proc _unit_before_each_some_text6() {
    //code...
    return('test')
}

proc _unit_test_empty_0() {
    _print('SUCCESSFUL')
    _assert_empty(array())
}

proc _unit_test_empty_1() {
    _assert_empty(null, 'SUCCESSFUL')
}

proc _unit_test_empty_2() {
    _assert_empty(array('1' : 1), 'SUCCESSFUL')
}

proc _unit_test_not_empty_0() {
    _print('SUCCESSFUL')
    _assert_not_empty(array(1))
    _assert_not_empty('123')
    _assert_not_empty(null)
}

proc _unit_test_not_empty_2() {
    _assert_not_empty(array(), 'SUCCESSFUL')
}

proc _unit_test_not_empty_2() {
    _assert_not_empty('', 'SUCCESSFUL')
}
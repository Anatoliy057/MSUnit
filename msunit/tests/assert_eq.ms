proc _unit_before_all_some_text3() {
    //code...
    return('hello')
}

proc _unit_before_each_some_text3() {
    //code...
    return('test')
}

proc _unit_test_eq_0() {
    _print('SUCCESSFUL')
    _assert_equals(array(1, 2, 3), array(1, 2, 3))
}

proc _unit_test_eq_1() {
    _assert_equals(array(1, 2, 3), array(1, 2, 4), 'SUCCESSFUL')
}

proc _unit_test_not_eq_0() {
    _print('SUCCESSFUL')
    _assert_not_equals(array(1, 2, 3), array(1, 2, 4))
}

proc _unit_test_not_eq_1() {
    _assert_not_equals(array(1, 2, 3), array(1, 2, 3), 'SUCCESSFUL')
} 
proc _unit_before_all_some_text2() {
    //code...
    return('hello')
}

proc _unit_before_each_some_text2() {
    //code...
    return('test')
}

proc _unit_test_true_0() {
    _print('SUCCESSFUL')
    _assert_true(1 == 1, 'Wow!')
}

proc _unit_test_true_1() {
    _assert_true(1 == 2, 'SUCCESSFUL')
}

proc _unit_test_false_0() {
    _print('SUCCESSFUL')
    _assert_false(1 == 2)
}

proc _unit_test_false_1() {
    _assert_false(1 == 1, 'SUCCESSFUL')
}
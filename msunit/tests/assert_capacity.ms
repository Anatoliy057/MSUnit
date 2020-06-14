proc _unit_before_all_some_text5() {
    //code...
    return('hello')
}

proc _unit_before_each_some_text5() {
    //code...
    return('test')
}

proc _unit_test_size_0() {
    _print('SUCCESSFUL')
    _assert_size(3, array(1, 2, 5))
}

proc _unit_test_size_1() {
    _assert_size(5, array(), 'SUCCESSFUL')
}

proc _unit_test_len_0() {
    _print('SUCCESSFUL')
    _assert_length(3, array(1, 2, 3))
    _assert_length(3, '123')
}

proc _unit_test_len_1() {
    _assert_length(4, '123', 'SUCCESSFUL')
}
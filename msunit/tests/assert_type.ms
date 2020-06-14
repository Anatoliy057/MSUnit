proc _unit_before_all_some_text7() {
    //code...
    return('hello')
}

proc _unit_before_each_some_text7() {
    //code...
    return('test')
}

proc _unit_test_type_0() {
    _print('SUCCESSFUL')
    _assert_type('ms.lang.array', array(1, 2, 7))
}

proc _unit_test_type_1() {
    _assert_type('ms.lang.array', 7, 'SUCCESSFUL')
}
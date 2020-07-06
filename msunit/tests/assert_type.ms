proc _test_type_0() {
    _assert_type('ms.lang.array', array(1, 2, 7))
    _print('SUCCESSFUL')
}

proc _test_type_1() {
    _assert_type('ms.lang.array', 7, 'SUCCESSFUL')
}
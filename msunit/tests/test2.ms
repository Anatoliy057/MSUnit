proc _unit_before_all_some_text0() {
    //code...
    return('hello')
}

proc _unit_before_each_some_text0() {
    //code...
    return('test')
}

proc _unit_test_0_assert_out() {
    _skip_test()
    sleep(100)
}

proc _unit_test_0_proc_out() {
    _skip_test()
    while(true) {
        sleep(1)
        _assert_true(true)
    }
}

proc _unit_test_unex_throw() {
    throw(Exception, 'SUCCESSFUL')
}

proc _unit_test_simular() {
    _print('Test 2')
}
proc _test_assert_out() {
    _print('SUCCESSFUL')
    sleep(100)
}

proc _test_proc_out() {
    _print('SUCCESSFUL')
    while(true) {
        sleep(1)
        _assert_true(true)
    }
}
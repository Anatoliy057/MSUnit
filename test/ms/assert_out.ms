proc _test_assert_out() {
    sleep(100)
}

proc _test_proc_out() {
    while(true) {
        sleep(1)
        _assert_true(true)
    }
}
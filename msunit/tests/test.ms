proc _test_user_log() {
    _print('print')
    _println('ln')
}

proc _test_localPackages() {
    _assert_true(_from_local_packages())
}

proc _test_resource() {
    @file = read(_unit_resource('file.txt'))
    @folder_file = read(_unit_resource('folder.file.txt'))
    _assert_equals(@file, @folder_file)
}

proc _test_time_limit_1() {
    _assert_time_limit(0, 100)
    _print('Yellow time')
}

proc _test_time_limit_2() {
    _assert_time_limit(0, 0)
    _print('Red time')
}

proc _test_skip() {
    _skip_test()
}

proc _test_unex_throw() {
    throw(Exception, 'SUCCESSFUL')
}
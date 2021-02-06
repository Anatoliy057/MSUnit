proc _test_user_log() {
    _print('print')
    _println('ln')
}

proc _test_util() {
    _assert_true(_from_util())
}

proc _test_resources() {
    @file = read(_unit_get_resource('file.txt'))
    @folderFile = read(_unit_get_resource('folder/file.txt'))
    _assert_equals(@file, @folderFile)
}

proc _test_skip() {
    _skip_test()
}

proc _test_unex_throw() {
    throw(Exception, 'SUCCESSFUL')
}

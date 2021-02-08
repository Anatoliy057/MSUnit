proc _test_userLog_successfully() {
    _print('print')
    _println('ln')

    @state = _get_state_test()
    _assert_equals(string(@state['userLog']), 'println\n')
}

proc _test_extension_successfully() {
    _assert_true(_from_util())
}

proc _test_resources_successfully() {
    @file = read(_unit_get_resource('file.txt'))
    @folderFile = read(_unit_get_resource('folder/file.txt'))
    _assert_equals(@file, @folderFile)
}

proc _test_skip() {
    _skip_test()
}

proc _test_unex_throw_fail() {
    throw(Exception, 'SUCCESSFUL')
}

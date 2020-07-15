proc _test_booleanish_false() {
    _assert_false_obj(array())
    _assert_false_obj(null)
    _assert_false_obj('')
}

proc _test_booleanish_true() {
    _assert_true_obj(array(57))
    _assert_true_obj(57)
    _assert_true_obj('hello')
}
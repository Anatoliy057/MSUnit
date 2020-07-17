proc _test_unex_throw1() {
    throw(Exception, 'SUCCESSFUL')
}

proc _test_unex_throw2() {
    _println('SUCCESSFUL')
}

proc _test_simular() {
    _println('SUCCESSFUL')
    _print('Test 2')
    return(null)
}

proc _after_each() {

}
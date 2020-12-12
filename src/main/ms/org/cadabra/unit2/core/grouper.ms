array proc _msunit_new_grouper(array @setting, array @testProcs) {

}

_msunit_include_add(closure() {

    array @attributes = associative_array()

    @attributes['init'] = closure(@m, @self, array @setting, array @testProcs) {
        string @testGroups = file_resolve(@setting['test_setting'])
        array @groups

        if (file_exists(@testSetting)) {
            @groups = yml_decode(read(@testGroups))
        } else {
            @groups = 
        }
    }
})
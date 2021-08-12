array proc _msunit_get_procs_filter() {
    return(_msunit_get_class('ProcsFilter'))
}

// _msunit_include_add(closure() {
//     array @procsFilter = associative_array()

//     execute(closure() {
//         proc _msunit_() {}
//         include(_msunit_import_test_api())
//         @procs = get_procedures()
//         @map = associative_array()
//         foreach(@proc in @procs) {
//             @map[@proc] = true
//         }

//         @procsFilter['map'] = @map
//     })
    
//     proc _filter(@self, array @procs) {
//         @result = array()
//         @map = @self['map']
//         foreach(@proc in @procs) {
//             if (!array_index_exists(@map, @proc), @result[] = @proc)
//         }
//         return(@result)
//     }

//     _msunit_register_class('ProcsFilter', @procsFilter, array('filter': '_filter'))
// })

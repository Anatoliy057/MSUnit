proc _package_unit_static_get_id_thread() {
    return(reg_split('[ :]', _util_get_cur_thread())[1..])
}

proc _package_unit_static_get_name_thread() {
    return(_util_get_cur_thread()[cslice(length('(MSUNIT)')+1, -1)])
}

proc _package_unit_static_to_unit_thread(@name) {
    return('(MSUNIT) '.@name)
}

proc _package_unit_undef_proc() {
    return(null)
}
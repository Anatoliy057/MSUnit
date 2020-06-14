proc _package_unit_syn_get(@key) {
    return(import('__UNIT_SYNCHRON')[@key])
}

proc _package_unit_syn_set(string @key) {
    @monitor =  'unit_synchron_'.@key
    import('__UNIT_SYNCHRON')[@key] = @monitor
    return(@monitor)
}

export('__UNIT_SYNCHRON', array())
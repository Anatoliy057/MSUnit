proc _package_unit_syn_get(@key) {
    return(import('__unit_synchron')[@key])
}

proc _package_unit_syn_set(string @key) {
    @monitor =  'unit_synchron_'.@key
    import('__unit_synchron')[@key] = @monitor
    return(@monitor)
}
proc _package_unit_syn_get(@key) {
    return(import('org.cadabra.msunit.syn')[@key])
}

proc _package_unit_syn_set(string @key) {
    @monitor =  'unit_synchron_'.@key
    import('org.cadabra.msunit.syn')[@key] = @monitor
    return(@monitor)
}

export('org.cadabra.msunit.syn', array())
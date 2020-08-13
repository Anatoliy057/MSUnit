proc _unit_resource_init(@root) {

    _util_make_folder(@root, _util_sdn(), _util_ign())

    proc _init_paths(string @id, string @path, array @model) {
        if (is_file(@path)) {
            return()
        }
        @files = list_files(@path)
        foreach(@file in @files) {
            @full_path = @path._util_sdn().@file
            @key = if (@id, "@id.@file", @file)
            @model[@key] = @full_path
            _init_paths(@key, @full_path, @model)
        }
    }

    @model = array()
    _init_paths('', @root, @model)
    export('org.cadabra.msunit.resource_api', @model)
}

string proc _unit_resource(string @path) {
    @model = import('org.cadabra.msunit.resource_api')
    if (!array_index_exists(@model, @path)) {
        throw(IllegalArgumentException, "Unknown resource: @path")
    }
    return(@model[@path])
}
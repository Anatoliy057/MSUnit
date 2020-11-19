proc _unit_resources_init(@root) {

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

string proc _unit_get_resource(string @path) {
    @model = import('org.cadabra.msunit.resources')['root']
    if (!array_index_exists(@model, @path)) {
        throw(IllegalArgumentException, "Unknown resource: @path")
    }
    return(@model[@path])
}
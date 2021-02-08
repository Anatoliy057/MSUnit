array proc _msunit_parse_thread() {
    @idThread = x_get_current_thread()[25..]
    @splitted = split(':', @idThread)
    
    return(array(
        trimScript: @splitted[0],
        test: @splitted[1],
    ))
}

string proc _msunit_thread_name(string @trimScript, string @test) {
    return("(MSUnit) @trimScript:@test")
}

string proc _msutil_parse_stack_trace(array @stackTrace) {
    @builder = res_create_resource('STRING_BUILDER')

    for(@i = 0, @i < array_size(@stackTrace), @i++) {
        @trace = @stackTrace[@i]
        string_append(@builder, 'at ')
        string_append(@builder, @trace['id'])
        string_append(@builder, ':')
        string_append(@builder, @trace['file'])
        string_append(@builder, ':')
        string_append(@builder, @trace['line'])
        string_append(@builder, '.')
        string_append(@builder, @trace['col'])
        
        if (@i + 1 != array_size(@stackTrace)) {
            string_append(@builder, '\n')
        }
    }

    return(string(@builder))
}

void proc _msunit_make_file(string @fullpath, string @root) {
    if (file_exists(@fullpath)) {
        return()
    }

    array @folders = reg_split('[\\\\/]', @fullpath)

    if (array_size(@folders) > 1) {
        @folders = @folders[..-2]
    } else {
        @folders = array()
    }
    _msunit_make_folders(@folders, @root)

	create_file(file_resolve(@fullpath))
}

void proc _msunit_make_folder(string @fullpath, string @root) {
    if (file_exists(@fullpath)) {
        return()
    }

    array @folders = reg_split('[\\\\/]', @fullpath)
    _msunit_make_folders(@folders, @root)
}

void proc _msunit_make_folders(array @folders, string @root) {
    Resource @builder = res_create_resource('STRING_BUILDER')
	
	for(@i = 0, @i < array_size(@folders), @i++){
		string_append(@builder, @folders[@i])
        string_append(@builder, '/')

        @path = file_resolve(string(@builder))
		if(!string_starts_with(@root, @path) && !file_exists(@path)){
			create_dir(@path)
		}
	}
}

array proc _msunit_get_all_scripts(string @path) {
    @files = array()
    @listFiles = list_files(@path)
    foreach(@file in @listFiles) {
        @pathToFile = file_resolve("@path/@file")
        if (!is_dir(@pathToFile)) {
            if (string_contains(@pathToFile, '.ms'), @files[] = @pathToFile)
        
        } else {
            array_push_all(@files, _msunit_get_all_scripts(@pathToFile))
        }
    }
    
    return(@files)
}

void proc _msunit_replace_in_array(array @source, array @replacement, boolean @strict = true, string @path = '') {
    foreach(@key: @value in @replacement) {
        if (!array_index_exists(@source, @key)) {
            if (@strict) {
                throw(NotFoundException, "Key \"@path.@key\" not found in source")
            } else {
                @source[@key] = @value
            }
        } else {
            if (typeof(@value) == typeof(@source[@key])) {
                if (is_array(@value)) {
                    _msunit_replace_in_array(@source[@key], @replacement[@key], @strict, "@path.@key")
                } else {
                    @source[@key] = @value
                }
            } else {
                throw(IllegalArgumentException, "Type mismatch in: @path.@key")
            }
        }
    }
}

array proc _msunit_array_minus(array @arr1, array @arr2) {
    if (is_associative(@arr1)) {
        throw(CastException, 'First array must be not associative array')
    } else if (is_associative(@arr2)) {
        throw(CastException, 'Second array must be not associative array')
    }
    @result = array()
    foreach(@val in @arr1) {
        if (!array_contains(@arr2, @val), @result[] = @val)
    }
    return(@result)
}

array proc _msunit_get_procs(@path) {
    @old_procs = get_procedures()
    include(@path)
    @new_procs = get_procedures()
    @procs = _msunit_array_minus(@new_procs, @old_procs)
    return(@procs)
}

proc _method(string @method, array @self) {
    return(execute_array(@arguments, @self[@method]))
}

proc _method_array(array @args) {
    return(execute_array(@args, @args[1][@args[0]]))
}

proc _get_else(array @a, @index, @else) {
    return(array_get(@a, @index, @else))
}

proc _get(array @a, @index) {
    return(array_get(@a, @index, null))
}

boolean proc _key_in(array @array, string @key) {
    return(array_index_exists(@array, @key))
}

boolean proc _contains(array @array, @value) {
    return(array_contains(@array, @value))
}

int proc _size(array @array) {
    return(array_size(@array))
}

boolean proc _is_empty(array @array) {
    return(array_size(@array) == 0)
}

boolean proc _is_blank(string @string) {
    return(length(@string) == 0)
}

boolean proc _reg_like(string @pattern, string @subject) {
    return(_is_blank(reg_replace(@pattern, '', @subject)))
}

proc _msunit_void() {}

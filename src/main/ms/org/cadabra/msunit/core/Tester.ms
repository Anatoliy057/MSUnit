array proc _msunit_new_tester(string @id, array @options) {
    array @self = associative_array()

    foreach(@key: @attr in _msunit_get_class('Tester')) {
        @self[@key] = @attr
    }

    @self['id'] = @id
    @self['options'] = @options
    @self['moduleSetting'] = @options['module']

    _method('init', @self)

    return(@self)
}

_msunit_include_add(closure() {
    array @attributes = associative_array()

    @attributes['init'] = closure(@m, @self) { 
        @caller = '~console'
        @moduleSetting = @self['moduleSetting']
        @options = @self['options']
        @id = @self['id']

        @messager = _msunit_get_validation_messager()
        @messages = array()
        @logger = _msunit_new_logger(@moduleSetting['outs'])
        @self['logger'] = @logger

        // Load and filter scripts of tests
        @pathToTests = @moduleSetting['rootTests']
        @pattern = @moduleSetting['testPattern']
        @scripts = _msunit_get_all_scripts(@pathToTests)
        @filteredScripts = array()
        foreach(@script in @scripts) {
            if (_reg_like(@pattern, @script)) {
                @filteredScripts[] = @script
            }
        }

        // Validate scripts of tests
        @lenghtRoot = length(@moduleSetting['rootTests'])
        @scriptValidator = _msunit_get_script_validator()
        @procsFilter = _msunit_get_procs_sorter()
        @testsMap = associative_array()
        @trimScripts = array()
        foreach(@script in @filteredScripts) {
            @trimScript = @script[cslice(@lenghtRoot + 1, -1)]
            @trimScripts[] = @trimScript
            @procs = _msunit_get_procs(@script)
            @filteredProcs = _method('filterProcs', @procsFilter, @procs, @options)
            @testsMap[_msunit_static_method('formatScript', 'Grouper', @trimScript)] = @filteredProcs['tests']
            array_push_all(@messages, _method('valid', @scriptValidator, @trimScript, @filteredProcs))
        }

        // Validate setting groups
        @pathToSettingGroups = @moduleSetting['settingGroups']
        array @updatedSettingGroups
        try {
            @settingGroups = yml_decode(read(@pathToSettingGroups))
            @groupsValidator = _msunit_get_groups_validator()
            @updatedSettingGroups = _method('updateSettingGroups', @groupsValidator, @settingGroups, @trimScripts)
            array_push_all(@messages, _method('validSettingGroups', @groupsValidator, @updatedSettingGroups, @trimScripts))
            write_file(@pathToSettingGroups, yml_encode(@updatedSettingGroups, true), 'OVERWRITE')
        } catch(FormatException @e) {
            @messages[] = _method('fatal', @messager, "Improperly formatted YML setting groups at @pathToSettingGroups")
        }

        try {
            _method('log', @self, @messages, @messager, @caller)
        } catch(Exception @e) {
            throw(Exception, "A fatal occurred during the initialization of module tests '@id', see the logs")
        }
        
        @self['trimScripts'] = @trimScripts
        @grouper = _msunit_new_grouper(@updatedSettingGroups, @testsMap, @options)
        @self['grouper'] = @grouper

        @countTests = 0
        foreach(@formatScript: @tests in @testsMap) {
            @countTests += array_size(@tests)
        }
        @self['countTests'] = @countTests
    }

    proc _msunit_build_task(@self, string @script, string @formatScript, array @testFilter, array @scriptResult) {
        @oldProcs = get_procedures()
        include(@script)
        @newProcs = get_procedures()
        @procs = _msunit_array_minus(@newProcs, @oldProcs)

        @options = @self['options']
        
        @procsFilter = _msunit_get_procs_sorter()
        @filteredProcs = _method('filterProcs', @procsFilter, @procs, @options)
        @tests = @filteredProcs['tests']

        if(!_method('isChosenGroup', @testFilter, @formatScript)) {
            return(closure() {})
        }

        @task = closure() {
            
            string @procBeforeAll = '_msunit_void'
            string @procBeforeEach = '_msunit_void'
            string @procAfterAll = '_msunit_void'
            string @procAfterEach = '_msunit_void'

            if (array_size(@filteredProcs['beforeAll']) != 0) {
                @procBeforeAll = @filteredProcs['beforeAll'][0]
            }

            if (array_size(@filteredProcs['beforeEach']) != 0) {
                @procBeforeEach = @filteredProcs['beforeEach'][0]
            }

            if (array_size(@filteredProcs['afterAll']) != 0) {
                @procAfterAll = @filteredProcs['afterAll'][0]
            }

            if (array_size(@filteredProcs['afterEach']) != 0) {
                @procAfterEach = @filteredProcs['afterEach'][0]
            }

            @time = -nano_time()
            @beforeAll
            try {
                @return = array(call_proc(@procBeforeAll))
                @beforeAll = if(typeof(@return[0]) == typeof(_msunit_void()), null, @return[0])
            
            } catch (Exception @e) {
                @time += nano_time()
                @exception = @e[]
                @exception['stackTrace'] = @exception['stackTrace'][..-3]
                
                @state = _msunit_new_test_state(@formatScript, @options)
                _method('setException', @state, @exception)
                @state['time'] = @time
                @scriptResult['before all'] = @state
                
                return()
            }
            
            foreach(@test in @tests) {
                if (!_method('isChosenTest', @testFilter, @formatScript, @test)) {
                    continue()
                }
                
                @state = _msunit_new_test_state(@formatScript, @options)
                @scriptResult[@test] = @state
                
                @nameThread = _msunit_thread_name(@formatScript, @test)
                x_new_thread(@nameThread, closure() {
                    @time = -nano_time()
                    try {
                        @return = array(call_proc(@procBeforeEach, @test))
                        @beforeEach = if(typeof(@return[0]) == typeof(_msunit_void()), null, @return[0])
                        
                        @argsTest = array_filter(array(@beforeAll, @beforeEach), closure(@i, @v) {return(@v != null)})
                        @return = array(call_proc_array(@test, @argsTest))
                        @return = if(typeof(@return[0]) == typeof(_msunit_void()), null, @return[0])
                        
                        call_proc(@procAfterEach, @test, @return)
                    
                    } catch(Exception @e) {
                        @exception = @e[]
                        @exception['stackTrace'] = @exception['stackTrace'][..-2]
                        _method('setException', @state, @exception)
                        
                    } finally {
                        @time += nano_time()
                        @state['time'] = @time
                    }
                })

                @sleep = 1
                x_thread_join(@nameThread, 1000)
                while(x_thread_is_alive(@nameThread)) {
                    @statusTime = ''
                    synchronized(@state) {
                        @state['assertTime'] -= 1
                        @state['testTime'] -= 1

                        if (@state['testTime'] <= 0) {
                            _method('setTestTimeout', @state)
                            x_stop_thread(@nameThread)
                        
                        } else if (@state['assertTime'] <= 0) {
                            _method('setAssertTimeout', @state)
                            x_stop_thread(@nameThread)
                        }
                    }

                    x_thread_join(@nameThread, 1000)
                }

                @self['countFinishedTests'] += 1;
            }

            @time = -nano_time()
            try {
                call_proc(@procAfterAll)
            
            } catch (Exception @e) {
                @time += nano_time()
                @exception = @e[]
                @exception['stackTrace'] = @exception['stackTrace'][..-3]
                
                @state = _msunit_new_test_state(@formatScript, @options)
                _method('setException', @state, @exception)
                @state['time'] = @time
                @scriptResult['after all'] = @state
                
                return()
            }
        }
        
        return(@task)
    }

    @attributes['test'] = closure(@m, @self, string @caller, array @userGroups) {
        _msunit_static_method('doCommands', 'Commander', @self, @userGroups)

        @moduleSetting = @self['moduleSetting']
        @rootTests = @self['moduleSetting']['rootTests']
        @options = @self['options']
        @countThreads = @options['core']['threads']
        @delay = @options['core']['delay']
        @trimScripts = @self['trimScripts']
        @grouper = @self['grouper']
        @countTests = @self['countTests']

        @messager = _msunit_get_validation_messager()
        @groupsValidator = _msunit_get_groups_validator()
        @messages = _method('validUserGroups', @groupsValidator, @userGroups, @grouper, @options)
        try {
            _method('log', @self, @messages, @messager, @caller)
        } catch(Exception @e) {
            return()
        }

        @testFilter = _msunit_new_test_filter(@options, @grouper)
        _method('compile', @testFilter, @userGroups, @options)
        
        //Marker procedure
        proc _unit() {}
        include(_msunit_import_test_api())
        include(@moduleSetting['extension'])

        @runner = _msunit_tasker_init_self('MSUnit script runner', @countThreads, @delay, false)
        @states = associative_array()
        foreach(@trimScript in @trimScripts) {
            @script = file_resolve("@rootTests/@trimScript")
            @scriptState = associative_array()
            @formatScript = _msunit_static_method('formatScript', 'Grouper', @trimScript)
            @states[@formatScript] = @scriptState
            _msunit_tasker_add(@runner, _msunit_build_task(@self, @script, @formatScript, @testFilter, @scriptState))
        }

        @self['countFinishedTests'] = 0
        _msunit_set_environment(@moduleSetting, @states)
        @time = -nano_time()
        _msunit_tasker_start(@runner)

        @size = _msunit_tasker_size_waiting(@runner)
        @prevCount = 0
        while(_msunit_tasker_complited(@runner) != @size) {
            @curretnCount = @self['countFinishedTests']
            if(@curretnCount != @prevCount) {
                @statusBar = res_create_resource('STRING_BUILDER', 50)
                @percent = integer(100 * @curretnCount / @countTests)
                @loadProgress = integer(@percent/2)
                
                for(@i = 0, @i < @loadProgress, @i++, string_append(@statusBar, '#'))
                
                for(@i = @loadProgress, @i < 50, @i++, string_append(@statusBar, ' '))
                
                @color
                if(@percent < 25) {
                    @color = color('DARK_RED')
                
                } if (@percent < 75) {
                    @color = color('YELLOW')
                
                } else {
                    @color = color('GREEN')
                }
                
                print("\r@color @percent% [@statusBar] @curretnCount/@countTests".color('PLAIN_WHITE'))
                
                @prevCount = @curretnCount
            }
        }
        
        @time += nano_time()
        _msunit_tasker_stop(@runner)
        _msunit_clear_environment()
        
        _method('logStates', @self, @caller, @states, @time)
    }

    @attributes['logStates'] = closure(@m, @self, string @caller, array @states, number @fullTime) {
        @separator = @self['options']['groups']['separator']
        @colors = @self['options']['log']['colors']
        @logger = @self['logger']
        @id = @self['id']
        @fullTime = @fullTime/1000000000

        array @failedTests = array()
        int @countTests = 0
        int @countFailures = 0
        int @countSkipped = 0
        
        @builder = res_create_resource('STRING_BUILDER')
        string_append(@builder, '\r                                                                ')
        string_append(@builder, '\n[TIME] ')
        string_append(@builder, "[@id] ")
        string_append(@builder,  simple_date('yyyy.MM.dd \'at\' HH:mm:ss'))
        string_append(@builder, '\n')
        string_append(@builder, '\n')
        foreach(@script: @tests in @states) {
            if(array_size(@tests) == 0) {
                continue()
            }
            
            @formatScript = _msunit_static_method('formatScript', 'Grouper', @script)

            string_append(@builder, color(@colors['script']))
            string_append(@builder, '\r###########################################################\n')
            string_append(@builder, 'Script: ')
            string_append(@builder, color('UNDERLINE'))
            string_append(@builder, @formatScript)
            string_append(@builder, color('PLAIN_WHITE'))
            string_append(@builder, '\n')
            string_append(@builder, color(@colors['default']))
            
            int @lcountTests = 0
            int @lcountFailures = 0
            int @lcountSkipped = 0
            
            foreach(@test: @state in @tests) {          
                @testMessage = @state['testMessage']
                @assertMessage = @state['assertMessage']
                @attentionTime = @state['attentionTime']/1000000000
                @stackTrace = @state['stackTrace']
                @time = @state['time']/1000000000
                @isSkipped = @state['skipped']
                @isSuccessful = @state['successful']
                @userLog = @state['userLog']
                
                @lcountTests++
                
                string_append(@builder, color(@colors['test']))
                string_append(@builder, '\n-----------------------------------------------------------\n')
                if (@isSkipped) {
                    @lcountSkipped++
                    string_append(@builder, color(@colors['testSkip']))
                    string_append(@builder, '### ')
                    string_append(@builder, color(@colors['default']))
                    string_append(@builder, 'Test: ')
                    string_append(@builder, color('ITALIC'))
                    string_append(@builder, color(@colors['test']))
                    string_append(@builder, @test)
                    string_append(@builder, color('PLAIN_WHITE'))
                    string_append(@builder, color(@colors['default']))
                    string_append(@builder, ' - skipped\n')
                    
                    continue()
                
                } else if (@isSuccessful) {
                    string_append(@builder, color(@colors['testSuccessful']))
                    string_append(@builder, '+++ ')
                    string_append(@builder, color(@colors['default']))
                
                } else {
                    @lcountFailures++
                    @formatScript = _msunit_static_method('formatScript', 'Grouper', @script)
                    @failedTests[] = @formatScript.@separator.@test
                    
                    string_append(@builder, color(@colors['testFail']))
                    string_append(@builder, '--- ')
                    string_append(@builder, color(@colors['default']))
                }

                string_append(@builder, 'Test: ')
                string_append(@builder, color('ITALIC'))
                string_append(@builder, color(@colors['test']))
                string_append(@builder, @test)
                string_append(@builder, color('PLAIN_WHITE'))
                string_append(@builder, color(@colors['default']))
                string_append(@builder, ', time: ')
                if (@attentionTime >= @time) {
                    string_append(@builder, color(@colors['timeSuccessful']))
                
                } else {
                    string_append(@builder, color(@colors['timeAttention']))
                }

                string_append(@builder, @time)
                string_append(@builder, '\n')
                string_append(@builder, color(@colors['default']))                
                if (@assertMessage != null) {
                    string_append(@builder, color(@colors['message']))
                    string_append(@builder, 'Message: ')
                    string_append(@builder, @assertMessage)
                    string_append(@builder, '\n')
                    string_append(@builder, color(@colors['default']))
                }

                if (@userLog != '') {
                    string_append(@builder, color(@colors['userLog']))
                    string_append(@builder, '\n')
                    string_append(@builder, @userLog)
                    string_append(@builder, '\n')
                    string_append(@builder, color(@colors['default']))
                }

                if (!@isSuccessful) {
                    string_append(@builder, color(@colors['testLog']))
                    string_append(@builder, @testMessage)
                    string_append(@builder, '\n')
                    if(@stackTrace != null) {
                        string_append(@builder, _msutil_parse_stack_trace(@stackTrace))
                        string_append(@builder, '\n')
                    }

                    string_append(@builder, color(@colors['default']))
                }
            }

            string_append(@builder, '\n***********************************************************\n')

            _method('logStatistics', @self, @lcountTests, @lcountFailures, @lcountSkipped, @builder, @colors)  
            string_append(@builder, '\n')

            _method('log', @logger, string(@builder), @caller)
            
            @builder = res_create_resource('STRING_BUILDER')
            
            @countTests += @lcountTests
            @countFailures += @lcountFailures
            @countSkipped += @lcountSkipped
        }

        string_append(@builder, '\r===========================================================\n')

        if (array_size(@failedTests) != 0) {
            string_append(@builder, '\n')
            string_append(@builder, color(@colors['info']))
            string_append(@builder, 'Failed tests:\n')
            string_append(@builder, color(@colors['testFail']))                
            foreach(@failTest in @failedTests) {
                string_append(@builder, "- @failTest\n")
            }
            
            string_append(@builder, color(@colors['default']))
            string_append(@builder, '\n')
        }
        
        string_append(@builder, "Global statistics. Time: @fullTime, ")
        
        _method('logStatistics', @self, @countTests, @countFailures, @countSkipped, @builder, @colors)  
        
        _method('log', @logger, string(@builder), @caller)
    }

    @attributes['logStatistics'] = closure(@m, @self, int @tests, int @failures, int @skipped, @builder, @colors) {
        if (@tests != 0) {
            string_append(@builder, color(@colors['test']))
        
        } else {
            string_append(@builder, color(@colors['testFail']))
        }

        string_append(@builder, 'Tests run: ')
        string_append(@builder, @tests)
        string_append(@builder, color(@colors['default']))
        string_append(@builder, ', ')
        if (@failures == 0) {
            string_append(@builder, color(@colors['testSuccessful']))            
        
        } else {
            string_append(@builder, color(@colors['testFail']))
        }

        string_append(@builder, 'Failures: ')
        string_append(@builder, @failures)
        string_append(@builder, color(@colors['default']))
        string_append(@builder, ', ')
        if (@skipped == 0) {
            string_append(@builder, color(@colors['test']))            
        
        } else {
            string_append(@builder, color(@colors['testSkip']))            
        }

        string_append(@builder, 'Skipped: ')
        string_append(@builder, @skipped)
        string_append(@builder, color(@colors['default']))
    }

    @attributes['log'] = closure(@m, @self, array @messages, array @messager, string @caller) {
        @logger = @self['logger']
        @id = @self['id']
        @codeFatal = _method('getStatusCode', @messager, 'fatal')
        @valid = true
        foreach(@msg in @messages) {
            @codeMessage = _method('getStatusCode', @messager, @msg['status'])
            _method('log', @logger, _method('format', @messager, @msg, @id), @caller)
            @valid = @valid && @codeFatal != @codeMessage
        }

        if(!@valid) {
            throw(Exception, 'A fatal error')
        }
    }

    @attributes['tabcompleter'] = closure(@m, @self, array @args) {
        @input = @args[-1]
        @args = @args[..-2]
        @completions = _msunit_static_method('getCommands', 'Commander')
        array_push_all(@completions, array_filter(@self['grouper']['completions'], closure(@i, @c) {return(!array_contains(@args, @c))}))
        
        return(array_filter(@completions, closure(@key, @value) {
        	return(length(@input) <= length(@value) 
        			&& equals_ic(@input, substr(@value, 0, length(@input))))
        }))
    }

    _msunit_register_class('Tester', @attributes)
})

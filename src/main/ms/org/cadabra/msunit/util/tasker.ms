void proc _msunit_tasker_add(@self, closure @lymda) {
    @self['tasks'][] = @lymda
}

closure proc _msunit_private_tasker_pull(@self) {
    @index = array_size(@self['tasks']) - 1
    @removed = @self['tasks'][@index]
    array_remove(@self['tasks'], @index)
    
    return(@removed)
}

void proc _msunit_tasker_start(@self) {
    if (!@self['isRunning']) {
        @self['isRunning'] = true
        _msunit_private_tasker_run(@self)
    }
}

proc _msunit_private_tasker_run(@self) {
    @runnable = closure() {
        @currentTasks = @self['currentTasks']
        while(true) {
            for(@i = 0, @i < array_size(@currentTasks), @i++) {
                @task = @currentTasks[@i]
                if (!x_thread_is_alive(@task)) {
                    @self['canRunTasks']++
                    @self['countComplited']++
                    array_remove(@currentTasks, @i)
                    @i--
                }
            }

            @canRunTasks = @self['canRunTasks']
            if (@canRunTasks == 0) {
                try {
                    sleep(@self['delay'])

                } catch(InterruptedException @e) {
                    return()
                }

                continue()
            }

            @continue = false
            while (array_size(@self['tasks']) == 0) {
                try {
                    sleep(@self['delay'])

                } catch(InterruptedException @e) {
                    return()
                }

                if (@self['maxcanRunTasks'] != @canRunTasks && array_size(@currentTasks) != 0) {
                    @continue = true
                    break()
                }
            }

            if (@continue, continue())
            
            @countStartingTasks = min(@self['canRunTasks'], array_size(@self['tasks']))
            for(@i = 0, @i < @countStartingTasks, @i++) {
                if(x_is_interrupted(), return())
                @startingTask = _msunit_private_tasker_pull(@self)
                @id = @self['id'].'-'.@self['count']
                x_new_thread(@id, closure() {
                    execute(@startingTask)
                })
                @self['canRunTasks']--
                @self['count']++
                @currentTasks[] = @id
            }
        }
    }
    x_new_thread(@self['id'], @runnable)
}

proc _msunit_tasker_interrupt(@self) {
    x_interrupt(@self['id'])
    x_thread_join(@self['id'])
    foreach(@task in @self['currentTasks']) {
        x_interrupt(@task)
    }
}

proc _msunit_tasker_stop(@self) {
    x_interrupt(@self['id'])
    x_thread_join(@self['id'])
    foreach(@task in @self['currentTasks']) {
        x_stop_thread(@task)
    }
}

proc _msunit_tasker_is_run(@self) {
    return(x_thread_is_alive(@self['id']))
}

proc _msunit_tasker_size_waiting(@self) {
    return(array_size(@self['tasks']))
}

proc _msunit_tasker_size_running(@self) {
    return(array_size(@self['currentTasks']))
}

proc _msunit_tasker_complited(@self) {
    return(@self['countComplited'])
}

proc _msunit_tasker_init_self(string @id, int @canRunTasks, number @delay, boolean @start) {
    @self = array()
    @self['tasks'] = array()
    @self['id'] = @id
    @self['count'] = 0
    @self['delay'] = @delay
    @self['isRunning'] = @start
    @self['canRunTasks'] = @canRunTasks
    @self['maxcanRunTasks'] = @canRunTasks
    @self['currentTasks'] = array()
    @self['countComplited'] = 0

    if (@start) {
        _msunit_private_tasker_run(@self)
    }
    return(@self)
}

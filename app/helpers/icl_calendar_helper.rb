module IclCalendarHelper

    def time_difference(time1, time2)
        i = 0
        while time1 < time2 do
            time1 = time1.tomorrow()
            i+=1
        end
    end

	def get_calendar_event_view(course)
		assignments = course.assignments.select{|a| a.workflow_state=="published"}.sort_by{|a| a.lock_at}
		rows = []
		while assignments.length > 0 do
			row = []

			assignments.delete_if do |assignment|
                p assignment
				if row.length == 0 || row.last.lock_at <= assignment.unlock_at
					row.append(assignment)
                    true
				end
			end
            
			rows.append(row)
            p assignments.length
		end
        return rows
	end
end

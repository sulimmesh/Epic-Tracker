require 'pivotal-tracker'

PivotalTracker::Client.token = "your_pivotal_tracker_api_token"
@project = PivotalTracker::Project.find("your_project_id")

date_format = '%b %d'

SCHEDULER.every '10m', :first_in => 0 do
  if @project.is_a?(PivotalTracker::Project)
    epic = "your_epic_name"
    @current = PivotalTracker::Iteration.current(@project)

    storyList = @current.stories.select{ |s| 
      if s.labels
        s.labels.include?(epic.downcase) 
      end}

    storyAccept = storyList.select{|s| s.current_state == "accepted"}
    acceptCount = storyAccept.count
    acceptEstimate = 0
    if acceptCount > 0
      for i in 0..acceptCount-1
        if storyAccept[i].estimate
          acceptEstimate += storyAccept[i].estimate
        end
      end
    end

    storyFin = storyList.select{|s| s.current_state == "finished"}
    finCount = storyFin.count
    finEstimate = 0
    if finCount > 0
      for i in 0..finCount-1
        if storyFin[i].estimate
          finEstimate += storyFin[i].estimate
        end
      end
    end

    storyStart = storyList.select {|s| s.current_state == "started"}
    startCount = storyStart.count
    startEstimate = 0
    if startCount > 0
      for i in 0..startCount-1
        if storyStart[i].estimate
          startEstimate += storyStart[i].estimate
        end
      end
    end

    storyUnstart = storyList.select {|s| s.current_state == "unstarted"}
    unstartCount = storyUnstart.count
    unstartEstimate = 0
    if unstartCount > 0
      for i in 0..unstartCount-1
        if storyUnstart[i].estimate
          unstartEstimate += storyUnstart[i].estimate
        end
      end
    end

    totalCount = acceptCount+finCount+startCount+unstartCount
    totalEstimate = acceptEstimate+finEstimate+startEstimate+unstartEstimate


    send_event 'migration', {iteration_start: @current.start.strftime(date_format),
                           iteration_finish: @current.finish.strftime(date_format),
                           unstarted: unstartCount,
                           unstarted_estimate: unstartEstimate,
                           started: startCount,
                           started_estimate: startEstimate,
                           finished: finCount,
                           finished_estimate: finEstimate,
                           accepted: acceptCount,
                           accepted_estimate: acceptEstimate,
                           total: totalCount,
                           total_estimate: totalEstimate,
                           epic: epic
    }
  else
    puts 'Not a Pivotal project'
  end

end
# Epic-Tracker
Pivotal Tracker widget for Dashing to track and display project epics.

![](https://github.com/skeletalbassman/Epic-Tracker/blob/master/sample.png)

html to insert to your .erb file
```html
     <li data-row="1" data-col="1" data-sizex="2" data-sizey="1">
      <div data-id="epic" data-view="Epic" data-title="Epic: " data-moreinfo="" data-prefix=""></div>
    </li>
```

epic.html
```HTML
<h1>
  <span class="title" data-bind="title"></span>
  <span data-bind="epic"></span>
  <span data-bind="iteration_start"></span> - 
  <span data-bind="iteration_finish"></span>
</h1>
 
<div id="pivotal_stories">
  <table>
    <th>Status</th>
    <th>Stories</th>
    <th>Points</th>
    <tr class="light">
      <td>Accepted</td>
      <td><span data-bind="accepted"></span></td>
      <td><span class="points" data-bind="accepted_estimate"></span></td>
    </tr>
    <tr>
      <td>Finished</td>
      <td><span data-bind="finished"></span></td>
      <td><span class="points" data-bind="finished_estimate"></span></td>
    </tr>
    <tr class="light">
      <td>Started</td>
      <td><span data-bind="started"></span></td>
      <td><span class="points" data-bind="started_estimate"></span></td>
    </tr>
    <tr>
      <td>Unstarted</td>
      <td><span data-bind="unstarted"></span></td>
      <td><span class="points" data-bind="unstarted_estimate"></span></td>
    </tr>
    <tr class="light">
      <td>Total</td>
      <td><span data-bind="total"></span></td>
      <td><span class="points" data-bind="total_estimate"></span></td>
    </tr>
  </table>
  <div style="clear:both;"></div>
</div>
```

epic.scss
```css
// ----------------------------------------------------------------------------
// Sass declarations
// ----------------------------------------------------------------------------
$background-color:  rgb(37, 97, 136);
$light-color: rgb(72,141,186);

.widget-epic {
 
  background-color: $background-color;

	.light {
		background-color: $light-color;
	}
 }
 ```

epic.coffee
```coffeescript
class Dashing.Epic extends Dashing.Widget
```

epic.rb
```ruby
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
```

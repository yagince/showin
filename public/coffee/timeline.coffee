root = exports ? this
root.showTimeline = (url, listSelector) ->
  $.get(url).success( (timelines) ->
    json = $.parseJSON($(timelines).text())
    onSuccess(json, listSelector)
    data.iscrollview.refresh()
  )


root.onSuccess = (timelines, listSelector) ->
  if (timelines.length != 0)
    $(listSelector).children().remove()

  prependElement = ""
  $.each(timelines, (i, timeline) ->
    prependElement += new Timeline(timeline).toElement()
  )
  $(listSelector).prepend(prependElement).listview("refresh")
  data.iscrollview.refresh()

class Timeline
  constructor: (timeline) ->
    @timeline = timeline

  toRelativeTime: (time) ->
    diff = (new Date() - time)
    diffMinute = Math.floor(diff / (1000*60))
    if (diffMinute < 60)
      return "#{diffMinute}分前"
    diffHour = Math.floor(diffMinute / 60)
    if (diffHour < 24)
      return "#{diffHour}時間前"
    "#{time.getFullYear()}-#{time.getMonth()+1}-#{time.getDate()} #{time.getHours()}:#{time.getMinutes()}"

  toDate: (timeStr) ->
    datetimes = timeStr.replace(" +0900", "").split(/[- :]/)
    new Date(datetimes[0], datetimes[1]-1, datetimes[2], datetimes[3], datetimes[4], datetimes[5])

  toElement: =>
    """
    <li class="timeline">
      <img src="#{@timeline.user.profile_image_url}" class="profile-image">
      <h3 style="white-space:normal" class="username">#{@timeline.user.name} <span class="account-name">@#{@timeline.user.account_name}</span></h3>
      <p style="white-space:normal">#{@timeline.body}</p>
      <p class="ui-li-aside date"><strong>#{@toRelativeTime(@toDate(@timeline.created_at))}</strong></p>
    </li>
    """

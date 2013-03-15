root = exports ? this
root.renderTimelines = (url, listSelector, options={}) ->
  $.get(url).success( (timelines) ->
    json = $.parseJSON($(timelines).text())
    onSuccess(json, listSelector, options)
    data.iscrollview.refresh()
  )

root.timelineDetailHtml = (timeline) ->
  new Timeline(timeline).toShowElement()

root.onSuccess = (timelines, listSelector, options) ->
  if (timelines.length != 0)
    $(listSelector).children().remove()

  prependElement = ""
  $.each(timelines, (i, timeline) ->
    prependElement += new Timeline(timeline, options).toElement()
  )
  $(listSelector).prepend(prependElement).listview("refresh")
  data.iscrollview.refresh()

class Timeline
  constructor: (timeline, options={}) ->
    @timeline = timeline
    @showUrl = options.showUrl

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

  bodyWithLinks: (body) =>
    _tmp = body
    _tmp.replace(/[htps]+:\/\/[a-z0-9-_]+\.[a-z0-9-_:~%&\?\/.=]+[^:\.,\)\s*$]/ig, (url) ->
      '<a href="' + url + '?rho_open_target=_blank" target="_blank">' + url + '</a>'
    )

  toShowElement: => """
    <div>
      <div><img src="#{@timeline.user.profile_image_url}"></div>
      <div>#{@timeline.user.name} <span>@#{@timeline.user.account_name}</span></div>
    </div>
    <div>
      #{@bodyWithLinks(@timeline.body)}
    </div>
  """
  toElement: => """
    <li class="timeline">
      <a href="#{@showUrl}?id=#{@timeline.id}&account[name]=#{@timeline.account.name}&account[provider]=#{@timeline.account.provider}" data-transition="slide">
        <img src="#{@timeline.user.profile_image_url}" class="profile-image">
        <h3 class="username">#{@timeline.user.name} <span class="account-name">@#{@timeline.user.account_name}</span></h3>
        <p style="white-space:normal">#{@timeline.body}</p>
        <p class="ui-li-aside date"><strong>#{@toRelativeTime(@toDate(@timeline.created_at))}</strong></p>
      </a>
    </li>
  """

root = exports ? this
root.renderTimelines = (url, listSelector, templateSelector, options={}) ->
  $.get(url).success( (timelines) ->
    json = $.parseJSON($(timelines).text())
    onSuccess(json, listSelector, templateSelector, options)
    data.iscrollview.refresh()
  )

root.timelineDetailHtml = (timeline, templateSelector) ->
  new Timeline(timeline).toShowElement(templateSelector)

root.onSuccess = (timelines, listSelector, templateSelector, options) ->
  if (timelines.length != 0)
    $(listSelector).children().remove()

  prependElement = ""
  $.each(timelines, (i, timeline) ->
    prependElement += new Timeline(timeline, options).toElement(templateSelector)
  )
  $(listSelector).prepend(prependElement).listview("refresh")

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

  isRetweet: =>
    !!@timeline.original_data.retweeted_status

  toElement: (templateSelector) =>
    @timeline.relativeTime = @toRelativeTime(@toDate(@timeline.created_at))
    @timeline.isRetweet = @isRetweet()
    _.template($(templateSelector).text(), {timeline: @timeline, showUrl: @showUrl})

  toShowElement: (templateSelector) =>
    @timeline.relativeTime = @toRelativeTime(@toDate(@timeline.created_at))
    @timeline.isRetweet = @isRetweet()
    @timeline.bodyWithLinks = @bodyWithLinks(@timeline.body)
    _.template($(templateSelector).text(), {timeline: @timeline})

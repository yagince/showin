var toElement = function(timeline){
  return '<li class="timeline">' 
    + '<img src="' + timeline.user.profile_image_url + '" class="profile-image">'
    + '<h3 style="white-space:normal" class="username">' + timeline.user.name + '</h3>'
    + '<p style="white-space:normal">' + timeline.body + '</p>'
    + '<p class="ui-li-aside date"><strong>' + timeline.created_at + '</strong></p>'
    + '</li>';
}

var onSuccess = function(timelines, listSelector){
    if(timelines.length != 0) $(listSelector).children().remove();
    var prependElement = "";
    $.each(timelines, function(i, timeline) {
        prependElement += toElement(timeline);
    });
    $(listSelector).prepend(prependElement).listview("refresh");
    data.iscrollview.refresh();
}

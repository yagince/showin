// Generated by CoffeeScript 1.6.1
(function() {
  var Timeline, root,
    _this = this;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  root.showTimeline = function(url, listSelector, options) {
    if (options == null) {
      options = {};
    }
    return $.get(url).success(function(timelines) {
      var json;
      json = $.parseJSON($(timelines).text());
      onSuccess(json, listSelector, options);
      return data.iscrollview.refresh();
    });
  };

  root.onSuccess = function(timelines, listSelector, options) {
    var prependElement;
    if (timelines.length !== 0) {
      $(listSelector).children().remove();
    }
    prependElement = "";
    $.each(timelines, function(i, timeline) {
      return prependElement += new Timeline(timeline, options).toElement();
    });
    $(listSelector).prepend(prependElement).listview("refresh");
    return data.iscrollview.refresh();
  };

  Timeline = (function() {

    function Timeline(timeline, options) {
      var _this = this;
      this.toElement = function() {
        return Timeline.prototype.toElement.apply(_this, arguments);
      };
      this.timeline = timeline;
      this.showUrl = options.showUrl;
    }

    Timeline.prototype.toRelativeTime = function(time) {
      var diff, diffHour, diffMinute;
      diff = new Date() - time;
      diffMinute = Math.floor(diff / (1000 * 60));
      if (diffMinute < 60) {
        return "" + diffMinute + "分前";
      }
      diffHour = Math.floor(diffMinute / 60);
      if (diffHour < 24) {
        return "" + diffHour + "時間前";
      }
      return "" + (time.getFullYear()) + "-" + (time.getMonth() + 1) + "-" + (time.getDate()) + " " + (time.getHours()) + ":" + (time.getMinutes());
    };

    Timeline.prototype.toDate = function(timeStr) {
      var datetimes;
      datetimes = timeStr.replace(" +0900", "").split(/[- :]/);
      return new Date(datetimes[0], datetimes[1] - 1, datetimes[2], datetimes[3], datetimes[4], datetimes[5]);
    };

    Timeline.prototype.toElement = function() {
      return "<li class=\"timeline\">\n  <a href=\"" + this.showUrl + "?id=" + this.timeline.id + "&account[name]=" + this.timeline.account.name + "&account[provider]=" + this.timeline.account.provider + "\" data-transition=\"slide\">\n    <img src=\"" + this.timeline.user.profile_image_url + "\" class=\"profile-image\">\n    <h3 class=\"username\">" + this.timeline.user.name + " <span class=\"account-name\">@" + this.timeline.user.account_name + "</span></h3>\n    <p style=\"white-space:normal\">" + this.timeline.body + "</p>\n    <p class=\"ui-li-aside date\"><strong>" + (this.toRelativeTime(this.toDate(this.timeline.created_at))) + "</strong></p>\n  </a>\n</li>";
    };

    return Timeline;

  })();

}).call(this);

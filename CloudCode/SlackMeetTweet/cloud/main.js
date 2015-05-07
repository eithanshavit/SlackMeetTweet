var _ = require('underscore');

Parse.Cloud.define("tweet", function(req, res) {

  var Tweet = Parse.Object.extend("Tweet");
  var Pointer = Parse.Object.extend("Pointer");

  // Hold index
  var tweetIndex;

  // Fetch params
  var username = req.parmas.user_name;

  // Parse payload
  var payload = req.params.text;
  var jpgUrlExpression = "https?:\\\/\\\/(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,4}\\b([-a-zA-Z0-9@:%_\\+.~#?&\/\/=]*.[jJ][pP][Ee]?[gG])";
  var regex = new RegExp(jpgUrlExpression);
  // Determine payload's mime type
  var payloadMime = "text/plain"
  if (payload.match(regex)) {
    payloadMime = "image/jpeg";
  }

  // Find next tweet index
  var pointerQuery = new Parse.Query(Pointer);
  pointerQuery.first().then(function(pointer){
    // increment tweet index
    if (_.isUndefined(pointer)) {
      var pointer = new Pointer();
      pointer.set("index", 0);
    }
    else {
      pointer.increment("index");
    }
    return pointer.save();
  // Find tweet
  }).then(function(pointer) {
    tweetIndex = pointer.get("index") % pointer.get("slotsAllowed");
    var tweetQuery = new Parse.Query(Tweet);
    tweetQuery.equalTo("slot", tweetIndex);
    return tweetQuery.first();
  // Update or create tweet
  }).then(function(tweet) {
    if (_.isUndefined(tweet)) {
      var tweet = new Tweet();
      tweet.set("slot", tweetIndex);
    }
    tweet.set("payload", payload);
    tweet.set("user", username);
    tweet.set("mime", payloadMime);
    return tweet.save();
  // Success
  }).then(function(result) {
    res.success("Your tweetmeet has been sent!");
  // Error
  }, function(error) {
    res.error("failed to register tweet");
  });
});

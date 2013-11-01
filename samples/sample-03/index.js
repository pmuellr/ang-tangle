//----- init.coffee
;(function(__filename, __dirname, __basename) {
window.app = angular.module("app", []);

})("init.coffee", ".", "init");

//----- filters/LogTime.coffee
;(function(__filename, __dirname, __basename) {
var right;

app.filter(__basename, function() {
  return function(date) {
    var hh, mm, ss;
    hh = right("" + (date.getHours()), 2, 0);
    mm = right("" + (date.getMinutes()), 2, 0);
    ss = right("" + (date.getSeconds()), 2, 0);
    return "" + hh + ":" + mm + ":" + ss;
  };
});

right = function(string, len, pad) {
  while (string.length < len) {
    string = "" + pad + string;
  }
  return string;
};

})("filters/LogTime.coffee", "filters", "LogTime");

//----- routes.coffee
;(function(__filename, __dirname, __basename) {
var addRoute;

app.config(function($routeProvider, views) {
  $routeProvider.otherwise({
    redirectTo: "/"
  });
  addRoute($routeProvider, views, "home");
  return addRoute($routeProvider, views, "messages");
});

addRoute = function($routeProvider, views, name) {
  var url;
  if (name === "home") {
    url = "/";
  } else {
    url = "/" + name;
  }
  return $routeProvider.when(url, {
    controller: name,
    template: views[name]
  });
};

})("routes.coffee", ".", "routes");

//----- services/Logger.coffee
;(function(__filename, __dirname, __basename) {
var Logger;

app.service(__basename, Logger = (function() {
  function Logger() {
    this._verbose = false;
    this._messages = [];
  }

  Logger.prototype.getMessages = function() {
    return this._messages;
  };

  Logger.prototype.verbose = function(value) {
    if (value == null) {
      return this._verbose;
    }
    this._verbose = !!value;
    return this._verbose;
  };

  Logger.prototype.log = function(text) {
    var date;
    date = new Date;
    this._messages.push({
      date: date,
      text: text
    });
  };

  Logger.prototype.vlog = function(text) {
    if (!this._verbose) {
      return;
    }
    log(text);
  };

  Logger.prototype.clear = function() {
    return this._messages.splice(0, this._messages.length);
  };

  return Logger;

})());

})("services/Logger.coffee", "services", "Logger");

//----- views/body.coffee
;(function(__filename, __dirname, __basename) {
app.controller(__basename, function($scope, Logger) {
  var subTitle;
  Logger.log("created body controller");
  $scope.messages = Logger.getMessages();
  subTitle = "";
  $scope.getSubtitle = function() {
    if (subTitle === "") {
      return "";
    }
    return ": " + subTitle;
  };
  return $scope.setSubtitle = function(s) {
    return subTitle = s;
  };
});

})("views/body.coffee", "views", "body");

//----- views/home.coffee
;(function(__filename, __dirname, __basename) {
app.controller(__basename, function($scope, Logger) {
  Logger.log("created home controller");
  return $scope.setSubtitle("");
});

})("views/home.coffee", "views", "home");

//----- views/messages.coffee
;(function(__filename, __dirname, __basename) {
app.controller(__basename, function($scope, Logger) {
  Logger.log("created messages controller");
  $scope.setSubtitle("messages");
  $scope.messages = Logger.getMessages();
  $scope.clear = function() {
    return Logger.clear();
  };
});

})("views/messages.coffee", "views", "messages");

//----- --data--.coffee
;(function(__filename, __dirname, __basename) {
app.constant("data", {});

})("--data--.coffee", ".", "--data--");

//----- --views--.coffee
;(function(__filename, __dirname, __basename) {
app.constant("views", {
  "views/home": "<p>Welcome to the home page!",
  "views/messages": "<div ng-show=\"messages.length\">\n    <button class=\"btn btn-primary\" ng-click=\"clear()\">clear</button>\n</div>\n\n<div ng-hide=\"messages.length\" class=\"alert alert-info\">\n    no messages\n</div>\n\n<p>\n\n<table class=\"table table-striped\">\n    <tr ng-repeat=\"message in messages\">\n        <td>{{message.date | LogTime}}\n        <td width=\"100%\">{{message.text}}\n</table>\n"
});

})("--views--.coffee", ".", "--views--");

//# sourceMappingURL=index.js.map.json

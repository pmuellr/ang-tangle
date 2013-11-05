;(function(){

//----- --ang-tangle--.coffee
var AngTangle,
  __slice = [].slice;

AngTangle = {
  OneArgMethods: ["config", "run"],
  TwoArgMethods: ["animation", "constant", "controller", "directive", "factory", "filter", "provider", "service", "value"]
};

AngTangle.Init = (function() {
  function Init() {
    var getOneArgFunction, getTwoArgFunction, method, _i, _j, _len, _len1, _ref, _ref1;
    getOneArgFunction = function(module, method) {
      return function(thing) {
        if (module == null) {
          throw Error("module not defined in init script");
        }
        return module[method].call(module, thing);
      };
    };
    getTwoArgFunction = function(module, method) {
      return function(name, thing) {
        if (module == null) {
          throw Error("module not defined in init script");
        }
        return module[method].call(module, name, thing);
      };
    };
    _ref = AngTangle.OneArgMethods;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      method = _ref[_i];
      this[method] = getOneArgFunction(AngTangle.Module, method);
    }
    _ref1 = AngTangle.TwoArgMethods;
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      method = _ref1[_j];
      this[method] = getTwoArgFunction(AngTangle.Module, method);
    }
  }

  Init.prototype.module = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if (args.length !== 0) {
      if (AngTangle.Module != null) {
        throw Error("module() method called twice");
      }
      AngTangle.Module = angular.module.apply(angular, args);
    }
    return AngTangle.Module;
  };

  return Init;

})();

AngTangle.Script = (function() {
  function Script(module, scriptName) {
    var getOneArgFunction, getTwoArgFunction, method, _i, _j, _len, _len1, _ref, _ref1;
    this.module = module;
    this.scriptName = scriptName;
    getOneArgFunction = function(module, method) {
      return function(thing) {
        if (module == null) {
          throw Error("module not defined in init script");
        }
        return module[method].call(module, thing);
      };
    };
    getTwoArgFunction = function(module, method, scriptName) {
      return function(name, thing) {
        if (!thing) {
          thing = name;
          name = scriptName;
        }
        if (module == null) {
          throw Error("module not defined in init script");
        }
        return module[method].call(module, name, thing);
      };
    };
    _ref = AngTangle.OneArgMethods;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      method = _ref[_i];
      this[method] = getOneArgFunction(this.module, method);
    }
    _ref1 = AngTangle.TwoArgMethods;
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      method = _ref1[_j];
      this[method] = getTwoArgFunction(this.module, method, this.scriptName);
    }
    return this;
  }

  Script.prototype.module = function() {
    return this.module;
  };

  return Script;

})();

//----- init.coffee
;(function(AngTangle) {
AngTangle.module("app", []);

})(new AngTangle.Init());
if (!AngTangle.Module) throw Error("the init script must call AngTangle.module(name, requires[, configFn]) to create the module")

//----- filters/LogTime.coffee
;(function(AngTangle) {
var right;

AngTangle.filter(function() {
  var LogTime;
  return LogTime = function(date) {
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

})(new AngTangle.Script(AngTangle.Module, "LogTime"));

//----- routes.coffee
;(function(AngTangle) {
var routes;

AngTangle.config(routes = function($routeProvider, views) {
  var addRoute;
  addRoute = function(name, url) {
    if (url == null) {
      url = "/" + name;
    }
    return $routeProvider.when(url, {
      template: views["views/" + name],
      controller: name
    });
  };
  $routeProvider.otherwise({
    redirectTo: "/"
  });
  addRoute("home", "/");
  return addRoute("messages");
});

})(new AngTangle.Script(AngTangle.Module, "routes"));

//----- services/Logger.coffee
;(function(AngTangle) {
var Logger;

AngTangle.service(Logger = (function() {
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

})(new AngTangle.Script(AngTangle.Module, "Logger"));

//----- views/body.coffee
;(function(AngTangle) {
var body;

AngTangle.controller(body = function($scope, Logger) {
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

})(new AngTangle.Script(AngTangle.Module, "body"));

//----- views/home.coffee
;(function(AngTangle) {
var home;

AngTangle.controller(home = function($scope, Logger) {
  Logger.log("created home controller");
  return $scope.setSubtitle("");
});

})(new AngTangle.Script(AngTangle.Module, "home"));

//----- views/messages.coffee
;(function(AngTangle) {
var messages;

AngTangle.controller(messages = function($scope, Logger) {
  Logger.log("created messages controller");
  $scope.setSubtitle("messages");
  $scope.messages = Logger.getMessages();
  $scope.clear = function() {
    return Logger.clear();
  };
});

})(new AngTangle.Script(AngTangle.Module, "messages"));

//----- --data--.coffee
;(function(AngTangle) {
AngTangle.constant('data', {
  "someData": {
    "x": {
      "y": 4,
      "z": 5
    }
  }
});

})(new AngTangle.Script(AngTangle.Module, "--data--"));

//----- --views--.coffee
;(function(AngTangle) {
AngTangle.constant('views', {
  "views/home": "<p>Welcome to the home page!",
  "views/messages": "<div ng-show=\"messages.length\">\n    <button class=\"btn btn-primary\" ng-click=\"clear()\">clear</button>\n</div>\n\n<div ng-hide=\"messages.length\" class=\"alert alert-info\">\n    no messages\n</div>\n\n<p>\n\n<table class=\"table table-striped\">\n    <tr ng-repeat=\"message in messages\">\n        <td>{{message.date | LogTime}}\n        <td width=\"100%\">{{message.text}}\n</table>\n"
});

})(new AngTangle.Script(AngTangle.Module, "--views--"));


})();
//# sourceMappingURL=index.js.map.json

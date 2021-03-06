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

//----- init.litcoffee
;(function(AngTangle) {
AngTangle.module("app", []);

})(new AngTangle.Init());
if (!AngTangle.Module) throw Error("the init script must call AngTangle.module(name, requires[, configFn]) to create the module")

//----- routes.coffee
;(function(AngTangle) {
AngTangle.config(function($routeProvider, views) {
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
  return addRoute("hello");
});

})(new AngTangle.Script(AngTangle.Module, "routes"));

//----- views/hello.coffee
;(function(AngTangle) {
AngTangle.controller(function($scope) {
  return $scope.text = {
    world: "WORLD"
  };
});

})(new AngTangle.Script(AngTangle.Module, "hello"));

//----- views/home.coffee
;(function(AngTangle) {
AngTangle.controller(function($scope) {});

})(new AngTangle.Script(AngTangle.Module, "home"));

//----- --data--.coffee
;(function(AngTangle) {
AngTangle.constant('data', {});

})(new AngTangle.Script(AngTangle.Module, "--data--"));

//----- --views--.coffee
;(function(AngTangle) {
AngTangle.constant('views', {
  "views/hello": "<p>Hello, <span ng-bind=\"text.world\"></span>!!!</p>\n<p>Lots going on here:</p>\n<ul>\n<li>markdown for markup</li>\n<li>using <i>html</i> tags IN the markup</li>\n<li>it&#39;s github-flavored, so supports tables</li>\n</ul>\n<table>\n<thead>\n<tr>\n<th align=\"left\">col1</th>\n<th align=\"right\">col2</th>\n</tr>\n</thead>\n<tbody>\n<tr>\n<td align=\"left\">a</td>\n<td align=\"right\">1.1</td>\n</tr>\n<tr>\n<td align=\"left\">b</td>\n<td align=\"right\">2.2</td>\n</tr>\n<tr>\n<td align=\"left\">c</td>\n<td align=\"right\">3.3</td>\n</tr>\n</tbody>\n</table>\n",
  "views/home": "<p>Welcome to the home page!"
});

})(new AngTangle.Script(AngTangle.Module, "--views--"));


})();
//# sourceMappingURL=index.js.map.json

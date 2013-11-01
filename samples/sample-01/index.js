//----- init.coffee
;(function(__filename, __dirname, __basename) {
window.app = angular.module("app", []);

})("init.coffee", ".", "init");

//----- routes.coffee
;(function(__filename, __dirname, __basename) {
app.config(function($routeProvider, views) {
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

})("routes.coffee", ".", "routes");

//----- views/hello.coffee
;(function(__filename, __dirname, __basename) {
app.controller(__basename, function($scope) {
  return $scope.text = {
    world: "WORLD!!!"
  };
});

})("views/hello.coffee", "views", "hello");

//----- views/home.coffee
;(function(__filename, __dirname, __basename) {
app.controller(__basename, function($scope) {});

})("views/home.coffee", "views", "home");

//----- --data--.coffee
;(function(__filename, __dirname, __basename) {
app.constant("data", {});

})("--data--.coffee", ".", "--data--");

//----- --views--.coffee
;(function(__filename, __dirname, __basename) {
app.constant("views", {
  "views/hello": "<p>Hello, <span ng-bind=\"text.world\"></span>",
  "views/home": "<p>Welcome to the home page!"
});

})("--views--.coffee", ".", "--views--");

//# sourceMappingURL=index.js.map.json

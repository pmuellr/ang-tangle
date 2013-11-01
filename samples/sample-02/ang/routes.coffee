register.config ($routeProvider, views) ->

    addRoute = (name, url="/#{name}") ->
        $routeProvider.when url,
            template:  views["views/#{name}"]
            controller: name

    $routeProvider.otherwise redirectTo: "/"

    addRoute "home", "/"
    addRoute "hello"

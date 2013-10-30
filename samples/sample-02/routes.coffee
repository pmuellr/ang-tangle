app.config ($routeProvider, views) ->

    $routeProvider.otherwise redirectTo: "/"

    addRoute $routeProvider, views, "home"
    addRoute $routeProvider, views, "messages"

#-------------------------------------------------------------------------------
addRoute = ($routeProvider, views, name) ->
    if name is "home"
        url = "/"
    else
        url = "/#{name}"

    $routeProvider.when url,
        controller: name
        template:   views[name] 



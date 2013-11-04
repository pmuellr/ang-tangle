AngTangle.module.controller __basename, ($scope, Logger) ->
    Logger.log "created messages controller"

    $scope.setSubtitle "messages"

    $scope.messages = Logger.getMessages()

    $scope.clear = -> Logger.clear()

    return

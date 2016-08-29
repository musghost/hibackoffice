angular.module 'iventureFront'
  .run ($rootScope, $state, Admin) ->
    'ngInject'
    $rootScope.$on '$stateChangeStart', (e, toState) ->
      admin = toState.name.split('.')[0]

      if admin == 'admin' && !Admin.isAuthenticated()
        e.preventDefault()
        $state.go 'login'

    $rootScope.$on '$stateChangeSuccess', (event, toState) ->
      if toState.name != 'deuda'
        $('header').addClass 'slow'
        console.log 'hide'
      else
        $('header').removeClass 'slow'
        console.log 'show'
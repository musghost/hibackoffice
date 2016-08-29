angular.module 'iventureFront'
  .directive 'goto', ($location, $anchorScroll) ->
    restrict: 'A'
    link: (scope, elem) ->
      ###elem.on 'click', (e) ->
        setTimeout (->
          $location.hash 'main'
          $anchorScroll()
        ), 200###
      return
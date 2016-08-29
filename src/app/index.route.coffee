angular.module 'iventureFront'
  .config ($stateProvider, $urlRouterProvider) ->
    'ngInject'
    $stateProvider
      .state 'login',
        url: '/login'
        templateUrl: 'app/main/login.html'
        controller: 'LoginController'
        controllerAs: 'login'
      .state 'admin',
        url: '/admin'
        templateUrl: 'app/main/admin.html'
        controller: 'AdminController'
        controllerAs: 'main'
      .state 'admin.category',
        url: '/category/:id/'
        templateUrl: 'app/main/tables.html'
        controller: 'CategoryController'
        controllerAs: 'cat'
        resolve:
          type: ($stateParams) ->
            $stateParams.id
      .state 'admin.category.new',
        url: 'new'
        templateUrl: 'app/main/edit/deuda.html'
        controller: 'NewCategoryController'
        controllerAs: 'cat'
      .state 'admin.category.edit',
        url: ':item'
        templateUrl: 'app/main/edit/deuda.html'
        controller: 'EditCategoryController'
        controllerAs: 'cat'
        resolve:
          type: ($stateParams, Project, Case) ->
            Cat = eval($stateParams.id)
            Cat
              .findById({id: $stateParams.item})
              .$promise
              .then (result) ->
                result
    $urlRouterProvider.otherwise '/login'

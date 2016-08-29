angular.module 'iventureFront'
  .directive 'ngFiles', ($parse) ->
    fn_link = (scope, element, attrs) ->
      onChange = $parse(attrs.ngFiles)
      element.on 'change', (e) ->
        onChange scope, { $files: e.target.files }
    {
      link: fn_link
    }
  .controller 'AdminController', ($state) ->
    'ngInject'
    vm = this
    
    vm.types = [
      {id: 'Project', name: 'Proyectos'},
      {id: 'Case', name: 'Casos'}
    ]
    return

  .controller 'CategoryController', (type, Project, Case, toastr) ->
    'ngInject'
    vm = this
    vm.type = type


    Get = eval(type)
    Get.find()
      .$promise
      .then (response) ->
        vm.resources = response

    vm.delete = (event, id) ->
      event.preventDefault()
      Get.deleteById({id: id})
        .$promise
        .then ->
          toastr.success 'Elemento eliminado'
          Get.find()
            .$promise
            .then (response) ->
              vm.resources = response
        .catch ->
          toastr.error 'Error', 'No se pudo borrar el elemento'

    return
  .controller 'EditCategoryController', (type, toastr, $stateParams, $uibModal, base) ->
    'ngInject'
    vm = this

    vm.typeName = $stateParams.id

    vm.createProduct = (event) ->
      event.preventDefault()
      vm[vm.typeName]
        .$save()
        .then ->
          toastr.success 'Elemento guardado', 'Ahora puede revisarlo en el home.'
        .catch (error) ->
          if error.error?.message?
            toastr.error 'Error al guardar el producto.', error.message
          else
            toastr.error 'Error al guardar el producto.', 'Intente más tarde'
      return

    vm.setImage = (type) ->
      modal = $uibModal.open({
        animation: true
        templateUrl: 'app/main/edit/upload.html'
        size: 'md'
        controller: ($scope, base) ->
          formdata = new FormData()

          $scope.saveIt = ->
            $.ajax({
              url: "http://#{base}/api/containers/#{type}/upload"
              type: 'POST'
              data: formdata
              async: false
              success: (response) ->
                $scope.$close("http://#{base}/api/containers/#{type}/download/#{response.result.files.file[0].name}")
              error: () ->
                console.log 'error'
              cache: false
              contentType: false
              processData: false
            })
            return
          $scope.getTheFiles = ($files) ->
            angular.forEach $files, (value, key) ->
              formdata.append 'file', value
            console.log formdata
          return
      })
      modal.result.then (result) ->
        console.log result
        if result
          vm[vm.typeName].image = result

    vm[vm.typeName] = type
    return
  .controller 'NewCategoryController', (type, toastr, $stateParams, Project, Case, $state, $uibModal) ->
    'ngInject'
    vm = this
    vm.Project = {}
    vm.Case = {}

    vm.typeName = $stateParams.id
    Get = eval($stateParams.id)
    vm.createProduct = () ->
      Get
        .create(vm[vm.typeName])
        .$promise
        .then () ->
          toastr.success 'Elemento agregado', 'Se agregó el elemento a la tabla'
          $state.go 'admin.category', {id: vm.typeName}, {reload: true}
        .catch ->
          toastr.error 'Elemento agregado', 'Se agregó el elemento a la tabla'

    vm.setImage = (type) ->
      modal = $uibModal.open({
        animation: true
        templateUrl: 'app/main/edit/upload.html'
        size: 'md'
        controller: ($scope, base) ->
          formdata = new FormData()

          $scope.saveIt = ->
            $.ajax({
              url: "http://#{base}/api/containers/#{type}/upload"
              type: 'POST'
              data: formdata
              async: false
              success: (response) ->
                $scope.$close("http://#{base}/api/containers/#{type}/download/#{response.result.files.file[0].name}")
              error: () ->
                console.log 'error'
              cache: false
              contentType: false
              processData: false
            })
            return
          $scope.getTheFiles = ($files) ->
            angular.forEach $files, (value, key) ->
              formdata.append 'file', value
            console.log formdata
          return
      })
      modal.result.then (result) ->
        console.log result
        if result
          vm[vm.typeName].image = result

    return
  .controller 'LoginController', (Admin, $state) ->
    'ngInject'
    vm = @

    vm.log = {}

    vm.login = (e) ->
      e.preventDefault()
      Admin.login {rememberMe: vm.log.remember}, vm.log, () ->
        $state.go 'admin'
        return
      return
    return
angular.module 'iventureFront'
  .directive 'ngFiles', ($parse) ->
    fn_link = (scope, element, attrs) ->
      onChange = $parse(attrs.ngFiles)
      element.on 'change', (e) ->
        onChange scope, { $files: e.target.files }
    {
      link: fn_link
    }
    return
  .controller 'AdminController', ($state) ->
    'ngInject'
    vm = this
    
    vm.types = [
      {id: 'Course', name: 'Cursos'},
      {id: 'Track', name: 'Tracks'},
      {id: 'Guest', name: 'Invitados'}
    ]
    return
  .controller 'CategoryController', ($state, toastr, $stateParams, Course, Track, Guest) ->
    'ngInject'
    vm = this

    vm.id = $stateParams.id

    Get = eval $stateParams.id

    Get.find()
      .$promise
      .then (items) ->
        vm.resources = items
      .catch ->
          toastr.error 'Error', 'No se pudo borrar el elemento'

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

  .controller 'NewCategoryController', (toastr, $stateParams, Course, Track, Guest, $state, $uibModal) ->
    'ngInject'
    vm = this
    vm.Course = {}
    vm.Track = {}
    vm.Guest = {}

    vm.typeName = $stateParams.id
    Get = eval($stateParams.id)
    vm.createProduct = (event) ->
      event.preventDefault()
      Get
        .create(vm[vm.typeName])
        .$promise
        .then () ->
          toastr.success 'Elemento agregado', 'Se agregó el elemento a la tabla'
          $state.go 'admin.category', {id: vm.typeName}, {reload: true}
        .catch ->
          toastr.error 'Elemento agregado', 'Se agregó el elemento a la tabla'
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
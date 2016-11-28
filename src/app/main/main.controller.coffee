angular.module 'iventureFront'
  .directive 'stringToNumber', ->
    require: 'ngModel'
    link: (scope, element, attrs, ngModel) ->
      ngModel.$parsers.push (value) ->
        '' + value
      ngModel.$formatters.push (value) ->
        parseFloat value
      return
  .filter 'names', ->
    (input) ->
      types = []
      types['Course'] = 'Cursos'
      types['Track'] = 'Tracks'
      types['Guest'] = 'Invitados'
      types['Carousel'] = 'Aliados'

      types[input]


  .directive 'ngFiles', ($parse) ->
    fn_link = (scope, element, attrs) ->
      onChange = $parse(attrs.ngFiles)
      element.on 'change', (e) ->
        onChange scope, { $files: e.target.files }
    {
      link: fn_link
    }
  .controller 'AdminController', ($state, LoopBackAuth) ->
    'ngInject'
    vm = this
    
    vm.types = [
      {id: 'Course', name: 'Cursos'},
      {id: 'Track', name: 'Tracks'},
      {id: 'Guest', name: 'Invitados'},
      {id: 'Carousel', name: 'Aliados'}
    ]

    logout = (event) ->
      event.preventDefault()
      LoopBackAuth.clearUser()
      LoopBackAuth.clearStorage()
      $state.go 'login'

    return
  .controller 'CategoryController', ($state, toastr, $stateParams, Course, Track, Guest, Carousel, $uibModal) ->
    'ngInject'
    vm = this

    vm.id = $stateParams.id

    Get = eval $stateParams.id

    Get.find()
      .$promise
      .then (items) ->
        vm.resources = items
      .catch ->
        toastr.error 'Error', 'Hubo un error al buscar los elementos de esta categoría.'

    vm.delete = (event, id) ->
      event.preventDefault()

      modal = $uibModal.open({
        animation: true
        template: """
<div>
  <div class="modal-header">
    <h3 class="modal-title">Borrar elemento</h3>
  </div>
  <div class="modal-body">
    <p>¿Deseas eliminar el elemento?</p>
  </div>
  <div class="modal-footer">
    <button class="btn btn-danger" type="button" ng-click="$close(true)">Eliminar</button>
    <button class="btn btn-default" type="button" ng-click="$close(false)">Cancelar</button>
  </div>
</div>
"""
        size: 'md'
      })
      modal.result.then (result) ->
        if result
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

  .controller 'NewCategoryController', (toastr, $stateParams, Course, Track, Guest, Carousel, $state, $uibModal) ->
    'ngInject'
    vm = this
    vm.Course = {}
    vm.Track = {}
    vm.Guest = {}
    vm.Carousel = {}
    vm.loading = false

    Course.find().$promise.then (courses) ->
      vm.courses = courses

    vm.typeName = $stateParams.id
    Get = eval($stateParams.id)
    vm.createProduct = (event) ->
      event.preventDefault()
      vm.loading = true
      Get
        .create(vm[vm.typeName])
        .$promise
        .then () ->
          vm.loading = false
          toastr.success 'Elemento agregado', 'Se agregó el elemento a la tabla'
          $state.go 'admin.category', {id: vm.typeName}, {reload: true}
        .catch ->
          vm.loading = false
          toastr.error 'Elemento agregado', 'Se agregó el elemento a la tabla'

    vm.setFile = (type, fileType) ->
      modal = $uibModal.open({
        animation: true
        templateUrl: 'app/main/edit/upload.html'
        size: 'md'
        controller: ($scope, base) ->
          formdata = new FormData()
          $scope.loading = false
          $scope.saveIt = ->
            $scope.loading = true
            $.ajax({
              url: "http://#{base}/api/containers/#{type}/upload"
              type: 'POST'
              data: formdata
              success: (response) ->
                $scope.loading = false
                $scope.$close("http://#{base}/api/containers/#{type}/download/#{response.result.files.file[0].name}")
              error: () ->
                $scope.loading = false
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
          vm[vm.typeName][fileType] = result
        return

      return
    return

  .controller 'EditCategoryController', (type, toastr, $stateParams, $uibModal, base, Course) ->
    'ngInject'
    vm = this

    vm.loading = false

    vm.typeName = $stateParams.id
    Course.find().$promise.then (courses) ->
      vm.courses = courses

    vm.createProduct = (event) ->
      event.preventDefault()
      vm.loading = true
      vm[vm.typeName]
        .$save()
        .then ->
          toastr.success 'Elemento guardado', 'Ahora puede revisarlo en el home.'
          vm.loading = false
        .catch (error) ->
          vm.loading = false
          if error.error?.message?
            toastr.error 'Error al guardar el producto.', error.message
          else
            toastr.error 'Error al guardar el producto.', 'Intente más tarde'
      return

    vm.setFile = (type, fileType) ->
      modal = $uibModal.open({
        animation: true
        templateUrl: 'app/main/edit/upload.html'
        size: 'md'
        controller: ($scope, base) ->
          formdata = new FormData()
          $scope.loading = false
          $scope.saveIt = ->
            $scope.loading = true
            $.ajax({
              url: "http://#{base}/api/containers/#{type}/upload"
              type: 'POST'
              data: formdata
              success: (response) ->
                $scope.loading = false
                $scope.$close("http://#{base}/api/containers/#{type}/download/#{response.result.files.file[0].name}")
              error: () ->
                $scope.loading = false
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
          vm[vm.typeName][fileType] = result
        return

      return

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
  .controller 'PDFController', (Admin, $state, Extra, $uibModal, toastr) ->
    'ngInject'
    vm = @

    Extra.find().$promise.then (data) ->
      vm.extras = data

    vm.setFile = (type, id) ->
      modal = $uibModal.open({
        animation: true
        templateUrl: 'app/main/edit/upload-pdf.html'
        size: 'md'
        controller: ($scope, base) ->
          formdata = new FormData()
          $scope.loading = false
          $scope.saveIt = ->
            $scope.loading = true
            $.ajax({
              url: "http://#{base}/api/containers/#{type}/upload"
              type: 'POST'
              data: formdata
              success: (response) ->
                $scope.$close("http://#{base}/api/containers/#{type}/download/#{response.result.files.file[0].name}")
                $scope.loading = false
              error: () ->
                console.log 'error'
                $scope.loading = false
              cache: false
              contentType: false
              processData: false
            })
            return
          $scope.getTheFiles = ($files) ->
            angular.forEach $files, (value, key) ->
              formdata.append 'file', value
          return
      })
      modal.result.then (result) ->
        if result
          vm.extras[id].url = result
        return
      return

    vm.saveExtra = (event, id) ->
      event.preventDefault()
      vm.extras[id]
        .$save()
        .then ->
          toastr.success 'Elemento guardado', 'Ahora puede revisarlo en el home.'
        .catch (error) ->
          if error.error?.message?
            toastr.error 'Error al guardar el PDF.', error.message
          else
            toastr.error 'Error al guardar el PDF.', 'Intente más tarde'

      return
    return
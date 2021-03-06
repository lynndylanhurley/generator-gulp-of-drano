angular.module('<%= _.camelize(projectName.toLowerCase()) %>App', [
  'ngSanitize'
  'ui.router'
  'mgcrea.ngStrap'
  'angularSpinner'
  '<%= _.camelize(projectName.toLowerCase()) %>Partials'
])
  .config ($stateProvider, $urlRouterProvider, $locationProvider, $sceProvider) ->
    # disable sce
    # TODO: FIX
    $sceProvider.enabled(false)

    # push-state routes
    $locationProvider.html5Mode(true)

    # default to 404 if state not found
    $urlRouterProvider.otherwise('/404')

    # fix bug with spy cache
    $stateProvider
      .state 'index',
        url: '/'
        templateUrl: 'views/index.html'
        controller: 'IndexCtrl'

      .state 'index',
        url: ''
        templateUrl: 'views/index.html'
        controller: 'IndexCtrl'

      .state '404',
        url: '/404'
        templateUrl: 'views/404.html'

      .state 'style-guide',
        url: '/style-guide'
        templateUrl: 'views/style-guide.html'
        controller: 'StyleGuideCtrl'

      .state 'terms',
        url: '/terms'
        templateUrl: 'views/terms.html'

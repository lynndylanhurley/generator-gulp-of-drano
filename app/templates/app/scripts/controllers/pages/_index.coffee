angular.module('<%= _.camelize(projectName) %>App')
  .controller 'IndexCtrl', ($scope) ->
    console.log 'index'
    $scope.bsTitle = _([0..2])
      .map(-> Faker.random.bs_buzz() + '.')
      .join(' ')

    $scope.bsText = Faker.Lorem.paragraph()

    $scope.bsAction = Faker.random.bs_adjective()

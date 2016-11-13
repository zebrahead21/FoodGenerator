'use strict';

var app = angular.module('AngularFoodGeneratorApp', []);

app.controller('AngularFoodGeneratorController', ['$scope', '$http', function($scope, $http) {
  $scope.ingredients = [];

  function posting(ingredient_name) {
    $http.post('/putting_ingredient', { 'ingredient_name': ingredient_name })
         .success(function(data, status, headers, config) {
           $scope.ingredients = data;
         });
  }
  $scope.posting = posting; 




}]);


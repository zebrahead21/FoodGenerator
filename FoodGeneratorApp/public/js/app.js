'use strict';

var app = angular.module('AngularToDoListApp', []);

app.controller('AngularToDoListController', ['$scope', '$http', function($scope, $http) {

	function posting(ingredient_name) {
		$http.post('/putting_ingredient', {'ingredient_name':ingredient_name})
			 .success(function(data, status, headers, config) {
				$scope.ingredients = data;

      });
	}
	$scope.posting = posting; 













}]);
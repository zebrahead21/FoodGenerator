'use strict';
var app = angular.module('AngularFoodGeneratorApp', []);


app.controller('AngularFoodGeneratorController', ['$scope', '$http', '$timeout', '$interval', function($scope, $http, $timeout, $interval) {
  
	window.scope = $scope; // adaug variabila "$scope" ca un camp al obiectului "window"  

	var pos = 0;	
	$scope.choosedIngredients = {}; // aici se vor retine ingredientele pe care utilizatorul le-a ales.
	$scope.ingredients = []; // aici se retin sugestiile din partea serverului
	$scope.ingredientHolder = null; // aici este ng-model-ul care monitorizeaza #searchRecipesForm.input[name="ingredientHolder"]
	$scope.ingredientsFound = 0; // o variabila care este 0 in cazul in care nu s-a efectuat nicio cerere de sugestii, ori 1, in cazul
															// in care s-a efectuat o cere si urmeaza sa inregistram raspunsul si sa-l afisam sub forma de lista de sugestii in browser.
	$scope.recipes = [];

	$scope.retriveRecipes = function(recipeIngredients){
		$http.get('/recipes.json')
			.success(function(data, status, headers, config){
				$scope.recipes = data; 
			})
			.error(function(data, status, headers, config){
				console.log("Nu a reusit sa ia retetele de pe server.");
			});
	};	


	// Aceasta functie reprezinta o cerere catre server a unor sugestii care se potrivesc
	// inputului pe care utilizatorul aplicatiei il introduce in $searchRecipesForm.input[name='ingredientHolder'].

	$scope.retriveIngredients = function(ingredientHolder){

		$timeout(function(){		
						
			pos = -1;
			$scope.ingredients = null;
			
			if(ingredientHolder.length >= 3){
				$http.get('/ingredientsThatMatchIngredientHolder.json', {
					params: { "ingredientHolder": ingredientHolder }
				}).success(function(data, status, headers, config){
						if(data.length !== 0 && $scope.ingredientsFound === 0){
							$scope.ingredients = data;
							$scope.ingredientsFound = 1;
						}
						else{
							$scope.ingredients = null;
							$scope.ingredientsFound = 0;
						}					
					})		
					.error(function(data, status, headers, config){
						console.log("Nu a reusit sa ia ingredientele de pe server.");
					});
			}
			else{
				$scope.ingredients = null;
				$scope.ingredientsFound = 0;
			}
		}, 500);
	};
	
  	$scope.removeThisIngredient = function(ingredientID){
		delete $scope.choosedIngredients[ingredientID];
	};	

  function posting(ingredient_name) {
    var keys = Object.keys($scope.choosedIngredients);
    $http.post('/getIngredientsList', { 'ingredients_list': keys })
         .success(function(data, status, headers, config) {
           $scope.recipes = data;
         });
  }

  $scope.posting = posting; 


}]);



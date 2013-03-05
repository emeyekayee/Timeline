// declare a module
var tvAppModule = angular.module('tvApp', []);
 
// Configure the module.  Create some filters.
tvAppModule.filter('bwidth', function() {
  return angular.bind(UseBlock, UseBlock.bwidth);
});

tvAppModule.filter('rowKind', function() {
  return angular.bind(UseBlock, UseBlock.row_kind);
});









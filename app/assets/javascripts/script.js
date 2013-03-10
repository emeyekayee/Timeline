// declare a module
var tvAppModule = angular.module('tvApp', []);
 
// Configure the module.  Create some filters.
tvAppModule.filter('style_geo', function() {
  return angular.bind(TimePix, TimePix.style_geo);
});

tvAppModule.filter('rowKind', function() {
  return angular.bind(TimePix, TimePix.row_kind);
});

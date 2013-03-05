'use strict';

/* Controllers */

function ResourceListCtrl($scope, $http) {
  $scope.resources = [];

//$http.get('http://localhost:3000/schedule.json').
  $http.get('/schedule.json').

    success( function(data) {
      var param_names = ['minTime', 'inc', 't1', 't2'];
      param_names.forEach( function(name) {
        UseBlock[name] = data[name]
        console.log
        delete data[name]
      })
      console.log( "(t1 - minTime)-to-pixels: " + 
                   UseBlock.scale(UseBlock.t1 - UseBlock.minTime) )

      
      setTimeout( function() {
        var sc = $('#scrolling-container')
        sc.scrollLeft( UseBlock.scale(UseBlock.t1 - UseBlock.minTime) )
      }, 300 );

      window.json_data = data

      $scope.resources = Object.keys(data)
    }). // success

    error( function(data, status, headers, config) {
      console.log( '\nstatus: ' + status + 
                   '\nheaders(): ' + headers() +
                   '\nconfig: ' + config
                  )
      console.debug( data['Channel_737'] )
    }) // error
    return null;
}


var process_fns = { 
  TimeheaderDayNight: angular.bind(TimeheaderDayNightUseBlock, 
                                   TimeheaderDayNightUseBlock.process),
  TimeheaderHour:     angular.bind(TimeheaderHourUseBlock,     
                                   TimeheaderHourUseBlock.process),
  Channel:            angular.bind(ChannelUseBlock,            
                                   ChannelUseBlock.process)
}



function UseBlockListCtrl($scope) {
  if (! Array.isArray($scope.use_blocks)) $scope.use_blocks = [];
    
  var 
    resourceTag = $scope.resource,
    blocks      = window.json_data[ resourceTag ],
    rsrc_kind   = resourceTag.split('_')[0],
    process_fn   = process_fns[rsrc_kind];

  if (! process_fn) {
    console.log( 'Skipping use block with tag ' + resourceTag )
    return null
  }

  blocks.forEach( function(block) {
    $scope.use_blocks.push( process_fn(block.blk) )
  });
}

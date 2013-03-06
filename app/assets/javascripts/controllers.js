'use strict';

/* Controllers */

function ux_time_now() {
  return new Date().valueOf() / 1000
}

function ux_time_offset(uxt) {
  return uxt - UseBlock.minTime
}

function ux_time_offset_pix(uxt) {
  return UseBlock.scale( ux_time_offset(uxt) )
}

function scroll_to_ux_time(uxt) {
  var sc = $('#scrolling-container')
  sc.scrollLeft( ux_time_offset_pix(uxt) )
}

function scroll_to_t1() {
  scroll_to_ux_time( UseBlock.t1 )
}

function set_time_cursor() {
  var cursor = $('#current-time-cursor');
  var now_offset = ux_time_offset_pix( ux_time_now() );
  cursor.css( 'left',  now_offset + 'px' )
  setTimeout( set_time_cursor, 15 * 1000 )
}


function ResourceListCtrl($scope, $http) {
  $http.get('/schedule.json').

    success( function(data) {
      Object.keys(data.meta).forEach( function(name) {
        UseBlock[name] = data.meta[name]
      })
      delete data.meta
        
      window.json_data = data           // Park this here until we consume it.
      
      var tags = [];
      UseBlock.rsrcs.forEach( function(rsrc) {
        tags.push( rsrc.tag )
      })
      $scope.resources = tags

      setTimeout( scroll_to_t1, 100 )
      setTimeout( set_time_cursor, 1000 )
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

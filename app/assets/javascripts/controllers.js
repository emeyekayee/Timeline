'use strict';

/* Controllers */

function ux_time_now() {
  return new Date().valueOf() / 1000
}

function ux_time_offset(uxt) {
  return uxt - UseBlock.baseTime
}

function ux_time_offset_pix(uxt) {
  return UseBlock.secs_to_pix( ux_time_offset(uxt) )
}

function scroll_to_ux_time(uxt) {
  var sc = $('#scrolling-container')
  sc.scrollLeft( ux_time_offset_pix(uxt) )
}

function scroll_to_tlo() {
  scroll_to_ux_time( UseBlock.tlo )
}

function set_time_cursor() {
  var cursor = $('#current-time-cursor');
  var now_offset = ux_time_offset_pix( ux_time_now() );
  cursor.css( 'left',  now_offset + 'px' )
  setTimeout( set_time_cursor, 15 * 1000 )
}

function ux_time_of_pix(x) {
  return UseBlock.baseTime + UseBlock.pix_to_secs(x)
}

function build_url (t1, t2, inc) {
  var url = '/schedule.json'
  if (inc) url = '/schedule.json'
  if (t1 || t2 || inc) {url += '?t1=' + t1 + '&t2=' + t2 + '&inc=' + inc}
  return url
}

function init_resources($scope) {
  var rsrcs = UseBlock.rsrcs = UseBlock.meta.rsrcs
  $scope.rsrcs = rsrcs            // Defines the order of rows

  var tags = [];
  rsrcs.forEach( function(rsrc) {
    tags.push( rsrc.tag )
  })
  $scope.resources = tags         // 'resources' here is a misnomer XXXX

  setTimeout( scroll_to_tlo, 100 )
  setTimeout( set_time_cursor, 1000 )
}

function data_adder_factory($scope, $http) {
  return function(t1, t2, inc) {
    $http.get( build_url(t1, t2, inc) ).

      success( function(data) {
        Object.keys(data.meta).forEach( function(name) {
          UseBlock.meta[name] = data.meta[name]
        })
        UseBlock.baseTime = UseBlock.baseTime  || data.meta['minTime']

        window.json_data = data   // Park this here until we consume it.

        if (! inc) { init_resources($scope) }
        UseBlock.merge_metadata()
        $scope.tlo = UseBlock.tlo
        $scope.thi = UseBlock.thi
      }). // success

      error( function(data, status, headers, config) {
        console.log( '\nstatus: ' + status +
                     '\nheaders(): ' + headers() +
                     '\nconfig: ' + config
                    )
        console.debug( data.meta )
      }) // error
    return null;
  }
}

function ResourceListCtrl($scope, $http) {
  window.get_data = data_adder_factory($scope, $http)
  get_data();
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
    process_fn  = process_fns[rsrc_kind];

  if (! process_fn) {
    console.log( 'Skipping use block with tag ' + resourceTag )
    return null
  }

  blocks.forEach( function(block) {
    if (UseBlock.inc == 'lo') {
      console.log('Implement me !!! (inc=lo)')
      return null
    }
    $scope.use_blocks.push( process_fn(block.blk) )
  });
}

function LabelListCtrl($scope) {
  var tag = $scope.resource
  UseBlock.rsrcs[tag]
}

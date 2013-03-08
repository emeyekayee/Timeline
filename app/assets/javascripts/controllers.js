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


function ResourceListCtrl($scope, $http) {
  $.extend( $scope,
    {
      init_resources: function ($scope) {
        var rsrcs = UseBlock.rsrcs = UseBlock.meta.rsrcs

        $scope.rsrcs = rsrcs            // Define the order of rows:
        var tags = [];
        rsrcs.forEach( function(rsrc) {
          tags.push( rsrc.tag )
        })
        $scope.use_block_list_Ctls = {} // Experimental

        $scope.res_tags = tags
        setTimeout( scroll_to_tlo, 100 )
        setTimeout( set_time_cursor, 1000 )
      },

      get_data: function (t1, t2, inc) {
        $http.get( $scope.build_url(t1, t2, inc) ).

          success( function(data) {
            // BY HERE, THE BOGUS REQUEST IS ALREADY SEND TO SERVER
            UseBlock.meta = data.meta
            delete data.meta

            UseBlock.baseTime = UseBlock.baseTime  || UseBlock.meta['minTime']

            $scope.json_data = data   // Park this here until we consume it.

            if (! inc) {
              $scope.init_resources($scope)
            }
            UseBlock.merge_metadata()
            $scope.tlo = UseBlock.tlo  // Experimental
            $scope.thi = UseBlock.thi  // Experimental
          }). // success

          error( function(data, status, headers, config) {
            console.log( '\nstatus: ' + status +
                         '\nheaders(): ' + headers() +
                         '\nconfig: ' + config
                        )
            console.debug( data.meta )
          }) // error
        return null;
      },

      build_url: function (t1, t2, inc) {
        var url = '/schedule.json'
        if (inc) url = '/schedule.json'
        if (t1 || t2 || inc) {url += '?t1=' + t1 + '&t2=' + t2 + '&inc=' + inc}
        return url
      },

      more_data: function() {
        $scope.get_data( UseBlock.thi, UseBlock.thi + 3 * 3600, 'hi' )

        Object.keys($scope.json_data).forEach( function(key) {
          var controller = $scope.use_block_list_Ctls[key],
              blocks     =  $scope.json_data[key]
          controller.add_blocks( controller, blocks )
        })
      }
    });

  // $scope.rsrcs = [] // Didn't help.
  $scope.get_data();
} // end ResourceListCtrl


var process_fns = {
  TimeheaderDayNight: angular.bind(TimeheaderDayNightUseBlock,
                                   TimeheaderDayNightUseBlock.process),
  TimeheaderHour:     angular.bind(TimeheaderHourUseBlock,
                                   TimeheaderHourUseBlock.process),
  Channel:            angular.bind(ChannelUseBlock,
                                   ChannelUseBlock.process)
}


function UseBlockListCtrl($scope) {

  $scope.add_blocks = function( $scope, blocks ) {
    if (! $scope.process_fn) {
      console.log( 'Skipping uses block with tag ' + resourceTag )
      return null
    }

    blocks.forEach( function(block) {
      if (UseBlock.inc == 'lo') {
        console.log('Implement me !!! (inc=lo)')
        return null
      }
      $scope.use_blocks.push( $scope.process_fn(block.blk) )
    });
    console.log('Added blocks.')
  };


  if (! Array.isArray($scope.use_blocks)) $scope.use_blocks = [];

  var resourceTag = $scope.res_tag,
      blocks      = $scope.json_data[ resourceTag ],
      rsrc_kind   = resourceTag.split('_')[0];

  $scope.process_fn = process_fns[rsrc_kind];

  $scope.use_block_list_Ctls[resourceTag] = $scope

  $scope.add_blocks( $scope, blocks )
}


function UseBlockCtrl($scope) {
  var block = $scope.block // Just for debugger
}

function LabelListCtrl($scope) {
  var tag = $scope.res_tag
  UseBlock.rsrcs[tag] // Huh?
}

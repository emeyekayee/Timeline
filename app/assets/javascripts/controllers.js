'use strict';

/* Controllers */

function ux_time_now() {
  return new Date().valueOf() / 1000
}

function ux_time_offset(uxt) {
  return uxt - UseBlock.baseTime
}

function ux_time_offset_pix(uxt) {
  return UseBlock.secs_to_pix_scale( ux_time_offset(uxt) )
}

function scroll_to_ux_time(uxt) {
  var sc = $('#scrolling-container')
  sc.scrollLeft( ux_time_offset_pix(uxt) )
}

function scroll_to_tlo() {
  scroll_to_ux_time( UseBlock.tlo )
}

function scroll_to_thi() {
  scroll_to_ux_time( UseBlock.thi - 3 * 3600 )
}

function set_time_cursor() {
  var cursor = $('#current-time-cursor');
  var now_offset = ux_time_offset_pix( ux_time_now() );
  cursor.css( 'left',  now_offset + 'px' )
  setTimeout( set_time_cursor, 15 * 1000 )
}

function ux_time_of_pix(x) {
  return UseBlock.pix_to_secs(x)
}

function scroll_monitor() {
  var     sc = $('#scrolling-container'),
  l_vis_time = UseBlock.pix_to_secs( sc.scrollLeft() ),
  r_vis_time = l_vis_time + UseBlock.timeWindow;
  
  if ( r_vis_time > UseBlock.thi ) {
    RsrcListCtrlScope.$apply( RsrcListCtrlScope.more_data )
  } else if (l_vis_time < UseBlock.tlo) {
    RsrcListCtrlScope.$apply( RsrcListCtrlScope.less_data )
  }
  setTimeout( scroll_monitor, 100 )
}

$( function() { setTimeout( scroll_monitor, 100 ) } );

// $( function () {
//     $('#scrolling-container').scroll( function(event) {
//       // What "times" are visible at left, right side of window?
//       var l_vis_time = UseBlock.pix_to_secs( this.scrollLeft ),
//           r_vis_time = l_vis_time + UseBlock.timeWindow

//       if ( r_vis_time > UseBlock.thi ) {
//         RsrcListCtrlScope.$apply( RsrcListCtrlScope.more_data )
//       } else if (l_vis_time < UseBlock.tlo) {
//         RsrcListCtrlScope.$apply( RsrcListCtrlScope.less_data )
//       }
//     })
// })

function ResourceListCtrl($scope, $http) {
  $.extend( $scope,
    {
      init_resources: function () {    // Define the order of rows:
        $scope.rsrcs    = UseBlock.rsrcs = UseBlock.meta.rsrcs
        $scope.res_tags = [];
        $scope.rsrcs.forEach( function(rsrc) {
          $scope.res_tags.push( rsrc.tag )
        })

        $scope.use_block_list_Ctls = {} // To access lower-level scopes later on

        setTimeout( scroll_to_tlo, 100 )
        setTimeout( set_time_cursor, 1000 )
      },

      get_data: function (t1, t2, inc) {
        return $http.get( $scope.build_url(t1, t2, inc) ).

          success( function(data) {

            // UseBlock.meta = data.meta

            UseBlock.merge_metadata(data)
            delete data.meta

            $scope.json_data = data   // Park this here until we consume it.

            if (! inc) {
              $scope.init_resources($scope)
            }
          }). // success

          error( function(data, status, headers, config) {
            console.log( '\nstatus: ' + status +
                         '\nheaders(): ' + headers() +
                         '\nconfig: ' + config
                        )
            console.debug( data.meta )
          }) // error
      },

      build_url: function (t1, t2, inc) {
        var url = '/schedule.json'
        if (inc) url = '/schedule.json'
        if (t1 || t2 || inc) {url += '?t1=' + t1 + '&t2=' + t2 + '&inc=' + inc}
        return url
      },

      more_data: function() {
        if (! $scope.busy ) {
          $scope.busy = true;
          $scope.get_data( UseBlock.thi, UseBlock.thi + 3 * 3600, 'hi' ).
            success( function(data) {
              Object.keys($scope.json_data).forEach( function(key) {
                var controller = $scope.use_block_list_Ctls[key],
                    blocks     = $scope.json_data[key]
                controller.add_blocks( controller, blocks )
              })

            }); // errors handled above in get_data
          $scope.busy = false;
        }
      },

      less_data: function() {
        if (! $scope.busy ) {
          $scope.busy = true;
          $scope.get_data( UseBlock.tlo - 3 * 3600, UseBlock.tlo, 'lo' ).
            success( function(data) {
              Object.keys($scope.json_data).forEach( function(key) {
                var controller = $scope.use_block_list_Ctls[key],
                    blocks     = $scope.json_data[key]
                controller.add_blocks( controller, blocks )
              })

            }); // errors handled above in get_data
          $scope.busy = false;
        }
      },

      rsrcList: function() {
        if ( Array.isArray($scope.rsrcs) ) return $scope.rsrcs
        return [];
      }
    });
  window.RsrcListCtrlScope = $scope
  $scope.get_data();
} // end ResourceListCtrl
ResourceListCtrl.$inject = ['$scope', '$http'];


var process_fns = {
  TimeheaderDayNight: angular.bind(TimeheaderDayNightUseBlock,
                                   TimeheaderDayNightUseBlock.process),
  TimeheaderHour:     angular.bind(TimeheaderHourUseBlock,
                                   TimeheaderHourUseBlock.process),
  Channel:            angular.bind(ChannelUseBlock,
                                   ChannelUseBlock.process)
}


function UseBlockListCtrl($scope) {

  $.extend( $scope, {
    add_blocks: function ( $scope, blocks ) {

      if (UseBlock.inc == 'lo') {
        blocks.reverse().forEach( function(block) {
          $scope.use_blocks.unshift( $scope.process_fn(block.blk) )
        })
        return null
      }

      blocks.forEach( function(block) {
        $scope.use_blocks.push( $scope.process_fn(block.blk) )
      });
    }
  });


  if (! Array.isArray($scope.use_blocks)) $scope.use_blocks = [];

  var resourceTag = $scope.res_tag,
      blocks      = $scope.json_data[ resourceTag ],
      rsrc_kind   = resourceTag.split('_')[0];

  $scope.process_fn = process_fns[rsrc_kind];
  if (! $scope.process_fn) {
    console.log( 'Skipping use blocks with tag ' + resourceTag )
    return null
  }

  $scope.use_block_list_Ctls[resourceTag] = $scope

  $scope.add_blocks( $scope, blocks )
}
UseBlockListCtrl.$inject = ['$scope'];


function UseBlockCtrl($scope) {
  var block = $scope.block // Just for debugger
}
UseBlockCtrl.$inject = ['$scope'];


function LabelListCtrl($scope) {
  var tag = $scope.res_tag
  UseBlock.rsrcs[tag] // Huh?
}
LabelListCtrl.$inject = ['$scope'];


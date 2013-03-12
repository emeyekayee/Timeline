'use strict';


function justify_tweak() {
  var sc = $('#scrolling-container')
  if (sc) vis_justify_timespans( sc )
}

function vis_justify_timespans (sc) {
  $('.TimeheaderDayNightrow .timespan').each( function() {
    vis_justify_blockdivs (sc, $(this).children())
  })
}

function may_straddle (scrollLeft, scrollRight, blockdivs) {
  var bdiv, bleft, divs = [], i
  for (i = blockdivs.length - 1; i >= 0 ; i--) {
    bdiv  = blockdivs[i];
    bleft = parseInt(bdiv.style.left)  
    if (bleft  < scrollRight) {
      divs.push( bdiv )
      i--
      break
    }}
  if (bleft && bleft <= scrollLeft)
    return divs
  for (; i >= 0 ; i--) {
    bdiv = blockdivs[i];
    if (parseInt(bdiv.style.left) < scrollLeft) {
      divs.push( bdiv )
      break
    }}
    return divs
  }


function el_left(elt) { return parseInt(elt.style.left) }

function vis_justify_blockdivs (sc, blockdivs) {
  blockdivs.sort( function(a, b) { return el_left(a) - el_left(b) })
    
  var scrollLeft  = sc.scrollLeft(),
      scrollRight = scrollLeft + TimePix.pixWindow,
      bdivs       = may_straddle (scrollLeft, scrollRight, blockdivs);

  if (bdivs.length == 1)
    straddles_both( scrollLeft, scrollRight, common_data(bdivs[0]) )
  else {
    straddles_left  (scrollLeft,  common_data(bdivs.pop()));
    straddles_right (scrollRight, common_data(bdivs.pop()));
  }
}


function common_data(bdiv) {
  return {
    bdiv:       bdiv,
    tl:         $('.text_locator', bdiv),
    bdiv_left:  parseInt(bdiv.style.left),  
    bdiv_width: parseInt(bdiv.style.width)
  }
}

function straddles_both (scrollLeft, scrollRight, cd) {
  var  nleft = scrollLeft  - cd.bdiv_left
  var nwidth = scrollRight - scrollLeft
  relocate (cd.tl,  nleft, nwidth)
}



function straddles_right (scrollRight, cd) {
  if ( cd.bdiv_left + cd.bdiv_width > scrollRight ) {
    var room = scrollRight - parseInt( cd.tl.parent().css('left') )
    var jwidth = Math.max( room, 190 )
    relocate (cd.tl,     0, jwidth)
  }
}


function straddles_left (scrollLeft, cd) {
    if ( cd.bdiv_left + cd.bdiv_width > scrollLeft ) {
      var room = parseInt( cd.tl.parent().css('width') )
      var jleft  = Math.min (scrollLeft - cd.bdiv_left, room - 190 )
      var jwidth = room - jleft           // Should calculate  ^^^ this Fix Me
      relocate (cd.tl, jleft, jwidth)
    }
}

function relocate (tl, nleft, nwidth) {
  // tl.css(  'left',  nleft + 'px' ) 
  // tl.css( 'width',  nwidth + 'px' )
  $(tl).stop().animate({ left: nleft, width: nwidth}, {duration: 800}) 
  // 'fast' { queue: true, duration: 200 }
}



/* Controllers */

function ResourceListCtrl($scope, $http) {
  $.extend( $scope,
    {
      init_resources: function () {    
        $scope.rsrcs    = UseBlock.rsrcs = TimePix.meta.rsrcs
        $scope.res_tags = [];   // ^^ Defines the order of rows
        $scope.rsrcs.forEach( function(rsrc) {
          $scope.res_tags.push( rsrc.tag )
        })
        $scope.use_block_list_Ctls = {} // To access lower-level scopes later on

        setTimeout( TimePix.scroll_to_tlo, 100 )
        setTimeout( TimePix.set_time_cursor, 1000 )
        setTimeout( TimePix.scroll_monitor, 100 )
      },

      get_data: function (t1, t2, inc) {
        return $http.get( $scope.make_url(t1, t2, inc) ).

          success( function(data) {
            TimePix.merge_metadata(data)
            delete data.meta
            $scope.json_data = data   // Park this here until we consume it.

             if (! inc) { $scope.init_resources($scope) }
            $scope.busy = false;
          }). // success

          error( function(data, status, headers, config) {
            console.log( '\nstatus: ' + status +
                         '\nheaders(): ' + headers() +
                         '\nconfig: ' + config
                        )
            console.debug( data.meta )
            $scope.busy = false;
          }) // error
      },

      make_url: function (t1, t2, inc) {
        var url = '/schedule.json'
        if (t1 || t2 || inc)
          url += '?t1=' + t1 + '&t2=' + t2 + '&inc=' + inc
        return url
      },

      rq_data: function(t1, t2, inc) {
        if (! $scope.busy ) {
          $scope.busy = true;
          $scope.get_data( t1, t2, inc ).
            success( function(data) {
              Object.keys($scope.json_data).forEach( function(key) {
                var controller = $scope.use_block_list_Ctls[key],
                    blocks     = $scope.json_data[key]
                controller.add_blocks( controller, blocks )
              })
            }); // errors handled above in get_data
        }
      },
      
      more_data: function() {
          $scope.rq_data( TimePix.thi, TimePix.next_hi(), 'hi' )
      },

      less_data: function() {
          $scope.rq_data( TimePix.next_lo(), TimePix.tlo, 'lo' )
      }
    });
  window.RsrcListCtrlScope = $scope
  $scope.get_data();
} // end ResourceListCtrl
ResourceListCtrl.$inject = ['$scope', '$http'];


function ab (o) { return angular.bind( o, o.process ) }

var process_fns = {
  TimeheaderDayNight: ab(TimeheaderDayNightUseBlock),
  TimeheaderHour:     ab(TimeheaderHourUseBlock),
  Channel:            ab(ChannelUseBlock)
}


function UseBlockListCtrl($scope) {

  $.extend( $scope, {

    add_blocks: function ( $scope, blocks ) {
      var how = 'push'
      if (UseBlock.inc == 'lo') {
        how = 'unshift'
        blocks = blocks.reverse()
      }                        

      blocks.forEach( function(block) {
        $scope.insert_block( $scope.process_fn(block.blk), how )
      })
    },

    insert_block: function ( block, how ) {
      $scope.use_blocks[how]( block )
    }
  });


  $scope.use_blocks = [];

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


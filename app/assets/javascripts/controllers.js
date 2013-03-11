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

  if (bdivs.length == 1) straddles_both( scrollLeft, scrollRight, bdivs[0] )
  else {
    maybe_relocate (scrollLeft, bdivs.pop());
    maybe_relocate_right (scrollRight , bdivs.pop());
  }
}


function straddles_both (scrollLeft, scrollRight, bdiv) {
  var tl = $('.text_locator', bdiv)
  // tl.css(  'left',  scrollLeft - parseInt(bdiv.style.left) + 'px' )
  // tl.css( 'width',  scrollRight - scrollLeft + 'px' )
  $(tl).stop().animate({  left:  scrollLeft - parseInt(bdiv.style.left),
                         width: scrollRight - scrollLeft },
                        'fast' ) // { queue: true, duration: 200 }
}


function maybe_relocate_right (scrollRight, bdiv) {
  var  bdiv_left = parseInt(bdiv.style.left);
  var bdiv_width = parseInt(bdiv.style.width);

  if ( bdiv_left + bdiv_width > scrollRight ) {
    var tl = $('.text_locator', bdiv)
    var room = scrollRight - parseInt( tl.parent().css('left') )
 // var jleft  = Math.min( scrollLeft - bdiv_left, room - 190 )
    var jwidth = Math.max( room, 190 )
    tl.css(  'left',  0     + 'px' ) // Should calculate  ^^^ this Fix Me
    tl.css( 'width',  jwidth + 'px' )
  }
}


function maybe_relocate (scrollLeft, bdiv) {
    var  bdiv_left = parseInt(bdiv.style.left);
    var bdiv_width = parseInt(bdiv.style.width);

    if ( bdiv_left + bdiv_width > scrollLeft ) {
      var tl = $('.text_locator', bdiv)
      var room = parseInt( tl.parent().css('width') )
      var jleft  = Math.min (scrollLeft - bdiv_left, room - 190 )
      var jwidth = room - jleft
      tl.css(  'left',  jleft + 'px' ) // Should calculate  ^^^ this Fix Me
      tl.css( 'width',  room - jleft + 'px' )
    }
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


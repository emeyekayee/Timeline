// grid.js
// Copyright (c) 2008-2011 Mike Cannon (http://github.com/emeyekayee/Timeline)
//                                     (michael.j.cannon@gmail.com)

var ResourceSchedule = Class.create({
    lowater:     1800,                          //  30 min
    hiwater:     3600,                          //  60 min
    ten_min:     600,
    fifteen_min: 900,
    //
    debug:       false,
    //
      
  initialize: function() {
    var wide              = document.viewport.getWidth() - 24;
    var ts0               = $$('.timespan')[0];
    this.spanwidth        = wide - ts0.offsetLeft - 4;

    this.gridElt             = $("multi_sched_view"); // Base this on ID= XXXX
    this.gridElt.style.width = wide + "px";           // + inline script init.

    this.init_time_bounds();

    this.init_timespans();

    Tooltip.debug = this.debug;

    ////////// Experimental -- toggle mouseovers, dragAlong ////////////////
    this.listen();
    //
    this.init_dragAlongs( $$('#'+this.gridElt.id + ' .rsrcRow') );
  },


  init_dragAlongs: function( das ) {
      DragAmong.create( das );

      // HandScrollGrid
  },

  listen: function() {
    this.gridElt.observe('mouseover', this.mouseOverOutHand);
    this.gridElt.observe('mouseout',  this.mouseOverOutHand);
  },
      
  ignore: function() {
    this.gridElt.stopObserving('mouseover', this.mouseOverOutHand);
    this.gridElt.stopObserving('mouseout',  this.mouseOverOutHand);
  },

  //////////////////////////////////////////////////////////////////////////
  mouseOverOutHand: function (evt) {    // not really a method
    var evtElt = evt.element();
    var eBlockdiv;;
    // Looking for only A's is arbitrary. But it (specifically its
    // included text) is used here rather than DIV, so mouse
    // isn't *always* activating a tooltip.
    if ((evtElt.tagName == 'A')  &&  (eBlockdiv = evtElt.up('.blockdiv'))) {
      Tooltip.display( evt, eBlockdiv );
    }
    evt.stop();
  },


  init_time_bounds: function () {
    // Time range [t0 ..tn ] is visible.
    var G = this.gridElt
    this.t0  = parseInt( G.getAttribute('starttime'));
    this.tn  = parseInt( G.getAttribute('endtime'));

    // Time range [tlo..thi] is where the DOM has data.
    this.tlo = this.t0;
    this.thi = this.tn;

    // Whan new_tlo or new_thi is non-null, an AJAX request is pending
    //  and will be the new bound when completed.
    this.new_tlo = null;  
    this.new_thi = null;
  },


  init_timespans: function () {
    var width = this.spanwidth;
    var t0 = this.t0;
    var tn = this.tn;

    this.timespans = $$( '#' + this.gridElt.id + ' .timespan').map(
        function(ts, ix) {
          return new ResourceUseTimeSpan (this, ts, width, t0, tn);
        }.bind(this));
  },


  slide_time: function ( delta ) {
    if ( this.new_thi || this.new_tlo ) {
      return false;  // One data request at a time.
    }
    this.t0 += delta;
    this.tn += delta;

    this.time_update_view();

    if (delta >= 0) {
      if ((this.thi - this.tn) < this.lowater) {
        this.new_thi = this.tn + this.hiwater; // flag: a request is pending
        this.request_data ({t1: this.thi, t2: this.new_thi, inc: "hi"});
      }
    } else {
      if ((this.t0 - this.tlo) < this.lowater) {
        this.new_tlo = this.t0 - this.hiwater; // flag: a request is pending
        this.request_data ({t1: this.new_tlo, t2: this.tlo, inc: "lo"});
      }
    }
  },


  // t1, t2  Lower, Upper  time bounds for which data is requested.
  // inc   One of: "lo", "hi".
  request_data: function ( parms ) {
    new Ajax.Request('grid/groupupdate', {parameters: parms});
  },


  // When we get here the just-arrived content has been inserted
  // into the document.  Adjust it for display:
  complete_data_request: function() {
    var o = this;
    if (o.new_tlo) {o.tlo = o.new_tlo; o.new_tlo = null};
    if (o.new_thi) {o.thi = o.new_thi; o.new_thi = null};

    this.slide_time( 0 );
  },


  time_update_view: function() {
    for (var i = 0, len = this.timespans.length; i < len; ++i) {
      var ts = this.timespans[i];
      ts.time_update_row_view(this.t0, this.tn);
    }
  },


  update_check: function() {
    if ( this.debug ) return;

    var oldness = ((new Date()).valueOf() / 1000) - this.t0;

    if (oldness >= this.ten_min  &&          // Or assume user manually
        oldness <  2 * this.ten_min)         //  moved view back
      this.slide_time( this.fifteen_min );
  }

}); // end class ResourceSchedule


//------------------------------------------------------------------------

var ResourceUseTimeSpan = Class.create({

  initialize: function(grid, ts, vis_width, t0, tn) {
    ts.previous().down('img').setOpacity(0.45);  // IE won't do this w/ CSS

    this.grid = grid;
    this.spanwidth = vis_width;
    this.t0 = t0;
    this.tn = tn;

    ts.insert('<div class="block0 blockdiv"></div>' +
              '<div class="blockn blockdiv"></div>');

    var children = ts.childElements();
    this.blockn = children.pop();
    this.block0 = children.pop();

    this.vis_blocks = [];  // Maintained by adjust_visible_time_bounds()
                           // Redundant for now.
  },

  canonize: function(b) {
    if ( ! b ) return false;
    if ('starttime' in b) return true;

    if (b.hasAttribute('starttime') && b.hasAttribute('endtime')) {
      b.starttime = parseInt(b.getAttribute('starttime'));
      b.endtime   = parseInt(b.getAttribute('endtime'));
      return true;
    }
    return false;
  },


  // Bubble block0/blockn markers to before/after the visible
  // elements in time range [t0..tn] and bless them.
  adjust_visible_time_bounds: function (t0, tn) {
    var b0 = this.block0;
    var bn = this.blockn;
    var n;

    while( (n = $(bn.next()))  && this.canonize(n)  && n.starttime < tn ) {
      n.insert( {after: bn} ).show();   // extend_up_thru
      this.vis_blocks.push(bn);
    }

    while( (n = $(b0.previous())) && this.canonize(n) && n.endtime > t0 ) {
      n.insert( {before: b0} ).show();  // extend_down_thru
      this.vis_blocks.unshift(n);
    }

    while( (n = $(b0.next())) && this.canonize(n) && n.endtime <= t0 ) {
      n.insert( {after: b0} ).hide();   // retract_up
      this.vis_blocks.shift();
    }

    while((n = $(bn.previous())) && this.canonize(n) && n.starttime >= tn ) {
      n.insert( {before: bn} ).hide();  // retract_down
      this.vis_blocks.pop();
    }
  },


  time_update_row_view: function(t0, tn) {
    this.t0 = t0;
    this.tn = tn;

    this.adjust_visible_time_bounds(t0, tn)
    this.set_places_and_widths_by_time(t0, tn);
  },


  set_places_and_widths_by_time: function(tMIN, tMAX) {
    var visibleTime = tMAX - tMIN;
    var timToPixScale =  this.spanwidth / visibleTime;

    var end = this.blockn;
    var blk = this.block0;
    //
    while ( (blk = blk.next()) != end ) {
      var visTimeStart = (blk.starttime < tMIN) ? tMIN : blk.starttime;
      var visTimeEnd   = (blk.endtime   > tMAX) ? tMAX : blk.endtime;

      var pixLeft  = ((visTimeStart  - tMIN)      * timToPixScale) // .round();
      blk.style.left  = pixLeft + "px";

      var pixWidth = ((visTimeEnd - visTimeStart) * timToPixScale) // .round();
      blk.style.width = pixWidth - 2 + "px";

      blk.down('.blockclip').style.width = pixWidth - 6 + "px";
    }
  }

}); // end class ResourceUseTimeSpan

//--------------------------------------------------------------------------


//--------------------------------------------------------------------------


function after_update() {
  if ( !window.grid ) {
    window.grid = new ResourceSchedule() ;
  }
  window.grid.complete_data_request();
};


document.observe('dom:loaded', function() {
  after_update();

  new PeriodicalExecuter( function(){window.grid.update_check()}, 30 );
  });

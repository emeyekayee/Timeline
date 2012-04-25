
class ResourceSchedule
  # Prototype properties
  lowater:     1800
  hiwater:     3600
  ten_min:      600
  fifteen_min:  900

  debug:       false

  constructor: (elt) ->
    @schedElt = elt
    @tss      = jQuery(".timespan", @schedElt)

    wide      = document.body.clientWidth - 24
    @spanwidth           = wide - @tss[0].offsetLeft - 4;
    @schedElt.width wide+"px"                 # @gridElt --> @schedElt XXXX
                                              # + inline script init.

    @init_time_bounds()
    @init_timespans()

    # Tooltip.debug = @debug

    # # ////////// Experimental -- toggle mouseovers, dragAlong //////////////
    # ?? @listen()
    # #
    # ?? @init_dragAlongs( $$('#'+@schedElt.id + ' .rsrcRow') );


    # init_dragAlongs: (das) ->
    #   DragAmong.create( das )

    # listen: ->
    #   @schedElt.observe('mouseover', @mouseOverOutHand)
    #   @schedElt.observe('mouseout',  @mouseOverOutHand)

    # ignore: ->
    #   @schedElt.stopObserving('mouseover', @mouseOverOutHand);
    #   @schedElt.stopObserving('mouseout',  @mouseOverOutHand);

    # ////////////////////////////////////////////////////////////////////////
    # mouseOverOutHand: function (evt) {    // not really a method
    #   var evtElt = evt.element();
    #   var eBlockdiv;;
    #   // Looking for only A's is arbitrary. But it (specifically its
    #   // included text) is used here rather than DIV, so mouse
    #   // isn't *always* activating a tooltip.
    #   if ((evtElt.tagName == 'A')  &&  (eBlockdiv = evtElt.up('.blockdiv'))){
    #     Tooltip.display( evt, eBlockdiv );
    #   }
    #   evt.stop();
    # },


  init_time_bounds: ->
    # Time range [@t0..@tn ] will be visible.
    # Time range [@tlo..@thi] is where the DOM has data.
    a = (parseInt($(@schedElt).attr t) for t in ['starttime', 'endtime'])
    [@tlo, @thi] = [@t0, @tn] = a

    # (@new_tlo || @new_thi) means An AJAX request is pending and will be
    @new_tlo = @new_thi = null   # the new bound when request is completed.

  init_timespans: ->
    @timespans = ( new ResourceUseTimeSpan( this, ts, @spanwidth, @t0, @tn) for ts in @tss )

  slide_time: (delta) ->
    return false  if ( @new_thi || @new_tlo )  # One data request at a time.
                                               # --OR-- queue the request  XXXX
    @t0 += delta
    @tn += delta

    @time_update_view()

    if delta >= 0
      if (@thi - @tn) < @lowater
        @new_thi = @tn + @hiwater
        @request_data {t1: @thi, t2: @new_thi, inc: "hi"}  # rm {}
    else
      if (@t0 - @tlo) < @lowater
        @new_tlo = @t0 - @hiwater
        @request_data {t1: @new_tlo, t2: @tlo, inc: "lo"}  # rm {}


  # t1, t2  Lower, Upper  time bounds for which data is requested.
  # inc     One of: "lo", "hi".  (Maybe obsolete, or not.)
  request_data: (parms) ->
    # new Ajax.Request '/events/groupupdate', {parameters: parms}
    jQuery.get '/tms_events/groupupdate', parms


  # Newly-arrived content has been inserted into the document.
  # Adjust it for display:
  complete_data_request: ->
    [ @tlo, @new_tlo ] = [ @new_tlo, null ] if @new_tlo
    [ @thi, @new_thi ] = [ @new_thi, null ] if @new_thi
    @slide_time 0


  time_update_view: ->
    for ts in @timespans
      ts.time_update_row_view( @t0, @tn )


  oldness: -> (new Date).valueOf / 1000 - @t0
  update_check: ->
    return if @debug
    age = @oldness            # Too old: assume user manually moved view back
    @slide_time @fifteen_min if age >= @ten_min  &&  age <  2 * @ten_min

# end class ResourceSchedule
# ------------------------------------------------------------------------

class ResourceUseTimeSpan

  constructor: (grid, ts, vis_width, t0, tn) ->
    jQuery(ts).prev().children('img').fadeTo(40, 0.45)# IE won't do this w/ CSS

    @grid = grid
    @spanwidth = vis_width
    @t0 = t0
    @tn = tn

    jQuery(ts).append('<div class="block0 blockdiv"></div>' +
                 '<div class="blockn blockdiv"></div>')
    children = jQuery(ts).children().get()
    @blockn = children.pop()
    @block0 = children.pop()

    @vis_blocks = []   # Maintained by adjust_visible_time_bounds()
                       # Redundant for now.


  canonize: (b) ->                      # *** CAUTION re: jQuery vs elt ***
    return false unless b               # *** CAUTION re: jQuery vs elt ***
    return true if 'starttime' in b     # *** CAUTION re: jQuery vs elt ***

    if b.hasAttribute('starttime') && b.hasAttribute('endtime')
      b.starttime = parseInt b.getAttribute('starttime')
      b.endtime   = parseInt b.getAttribute('endtime')
      return true

    false


  # Bubble block0/blockn markers to before/after the visible
  # elements in time range [t0..tn] and bless them.
  adjust_visible_time_bounds: (t0, tn) ->
    b0 = @block0
    bn = @blockn

    while (n = bn.nextElementSibling)  &&  @canonize(n)  &&  n.starttime < tn
      # n.insert( {after: bn} ).show();  // extend_up_thru
      $(n).insertBefore($(bn)).show()     # extend_up_thru
      @vis_blocks.push(bn);

    while (n = b0.previousElementSibling)  &&  @canonize(n)  &&  n.endtime > t0
      # n.insert( {before: b0} ).show(); // extend_down_thru
      $(n).insertAfter($(b0)).show()      # extend_down_thru
      @vis_blocks.unshift(n);

    while (n = b0.nextElementSibling)  &&  n.endtime <= t0
      # n.insert( {after: b0} ).hide();  // retract_up
      $(n).insertBefore($(b0)).hide()     # retract_up
      @vis_blocks.shift()

    while (n = bn.previousElementSibling)  &&  n.starttime >= tn
      # n.insert( {before: bn} ).hide(); // retract_down
      $(n).insertAfter($(bn)).hide()      # retract_down
      @vis_blocks.pop()


  time_update_row_view: (t0, tn) ->
    [ @t0, @tn ]               = [ t0, tn ]
    @adjust_visible_time_bounds    t0, tn
    @set_places_and_widths_by_time t0, tn

  set_places_and_widths_by_time: (tMIN, tMAX) ->
    timToPixScale =  @spanwidth / (tMAX - tMIN)
    [ blk, end ] = [ @block0, @blockn ]
    #
    while (blk = $(blk).next().get(0)) != end
      vts = Math.max  blk.starttime, tMIN
      vte = Math.min  blk.endtime,   tMAX

      pixLeft  = (vts - tMIN) * timToPixScale
      pixWidth = (vte - vts)  * timToPixScale

      blk = $(blk)
      blk.css( 'left', pixLeft + "px")
      blk.width( pixWidth - 2 + "px" )
      blk.children('.blockclip').width( pixWidth - 6 + "px" )


# end class ResourceUseTimeSpan

# --------------------------------------------------------------------------
# --------------------------------------------------------------------------

# Id name 'multi_sched_view' isn't right.  One schedule shows multiple
# resources over one timespan.  And with n>1 schedules the id for each
# will be different.

window.after_update = ->
  # make_sched = (ix, elt) -> new ResourceSchedule( $(elt) )

  # window.grids ||= jQuery('#multi_sched_view').map( make_sched ).get()
  window.grid ||= new ResourceSchedule( $('#multi_sched_view') )

  # window.grids.each( -> @complete_data_request() )
  window.grid.complete_data_request()

jQuery( -> window.after_update() )

#         new PeriodicalExecuter( function(){window.grid.update_check()}, 30 )

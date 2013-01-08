
class ResourceSchedule
  lowater:     1800
  hiwater:     3600
  ten_min:      600
  fifteen_min:  900
  debug:       false

  constructor: (@schedElt) ->
    @tss = $(".timespan", @schedElt)

    w = document.body.clientWidth
    @spanwidth = w - @tss[0].offsetLeft
    @schedElt.width w - 4 + "px"

    @init_time_bounds()
    @init_timespans()

    for e in [ 'mouseover', 'mouseout' ]
      @schedElt.delegate '.blockdiv a', e, InfoPopup.mouseOverOutHand


  # Time range [@t0..@tn ] will be visible.
  # Time range [@tlo..@thi] is where the DOM has data.
  init_time_bounds: ->
    [@tlo, @thi] = [@t0, @tn] =
      (parseInt($(@schedElt).attr t) for t in ['starttime', 'endtime'])

    @server_tz_offset = Math.round((@t0 - @ux_time_now()) / 3600) * 3600
    @new_tlo = @new_thi = null


  # (@new_tlo || @new_thi) means An AJAX request is pending.  The non-null
  # one will be the new bound when request is completed.
  request_pending: -> @new_thi || @new_tlo


  init_timespans: ->
    @timespans =
      (new ResourceUseTimeSpan(this, $(ts), @spanwidth, @t0,@tn) for ts in @tss)


  slide_time: (delta) ->
    @t0 += delta
    @tn += delta
    @time_update_view()
    @maybe_request_data delta


  maybe_request_data: (delta) ->
    if @request_pending()
      console.log('Ignoring slide_time request: ' + new Date)
      return # --OR-- queue the request  XXXX

    if delta >= 0
      if (@thi - @tn) < @lowater
        @new_thi = @tn + @hiwater
        @request_data {t1: @thi, t2: @new_thi, inc: "hi"}
    else
      if (@t0 - @tlo) < @lowater
        @new_tlo = @t0 - @hiwater
        @request_data {t1: @new_tlo, t2: @tlo, inc: "lo"}


  # t1, t2  Lower, Upper  time bounds for which data is requested.
  # inc     One of: "lo", "hi".
  request_data: (parms) -> $.get '/schedule/groupupdate', parms


  # Newly-arrived content has been inserted into the document.
  # Adjust it for display:
  complete_data_request: ->
    [ @tlo, @new_tlo ] = [ @new_tlo, null ] if @new_tlo
    [ @thi, @new_thi ] = [ @new_thi, null ] if @new_thi
    @slide_time 0


  time_update_view: ->
    for ts in @timespans
      ts.time_update_row_view( @t0, @tn )


  ux_time_now: -> Math.round((new Date).valueOf() / 1000)

  oldness: -> @ux_time_now() - @t0 + @server_tz_offset

  update_check: ->
    return if @debug
    age = @oldness()          # Too old: assume user manually moved view back
    @slide_time @fifteen_min if age >= @ten_min  # &&  age <  2 * @ten_min

# end class ResourceSchedule
# ------------------------------------------------------------------------

class ResourceUseTimeSpan

  constructor: (@grid, ts, @spanwidth, @t0, @tn) ->
    ts.prev().children('img').fadeTo(0, 0.45) # IE won't do this w/ CSS

    ts.append('<div class="block0 blockdiv"></div>' +
                 '<div class="blockn blockdiv"></div>')
    children = ts.children().get()
    [ @blockn, @block0 ] = [ children.pop(), children.pop() ]

    @vis_blocks = [] # Managed by adjust_visible_time_bounds(); Redundant now


  canonize: (b) ->
    return false unless b
    return true if 'starttime' in b

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

    while (n = bn.nextElementSibling)     && @canonize(n)  &&  n.starttime < tn
      $(n).insertBefore($(bn)).show()     # extend_up_thru
      @vis_blocks.push(bn);

    while (n = b0.previousElementSibling) && @canonize(n)  &&  n.endtime   > t0
      $(n).insertAfter($(b0)).show()      # extend_down_thru
      @vis_blocks.unshift(n);

    while (n = b0.nextElementSibling)     && n.endtime   <= t0
      $(n).insertBefore($(b0)).hide()     # retract_up
      @vis_blocks.shift()

    while (n = bn.previousElementSibling) && n.starttime >= tn
      $(n).insertAfter($(bn)).hide()      # retract_down
      @vis_blocks.pop()


  time_update_row_view: (t0, tn) ->
    [ @t0, @tn ]               = [ t0, tn ]
    @adjust_visible_time_bounds    t0, tn
    @set_places_and_widths_by_time t0, tn


  set_places_and_widths_by_time: (tMIN, tMAX) ->
    timeToPixScale =  (@spanwidth + 6) / (tMAX - tMIN) # Fudge factor
    [ blk, end ] = [ @block0, @blockn ]

    while (blk = $(blk).next().get(0)) != end
      vts = Math.max  blk.starttime, tMIN
      vte = Math.min  blk.endtime,   tMAX

      pixLeft  = Math.floor( (vts - tMIN) * timeToPixScale )
      pixRight = Math.floor( (vte - tMIN) * timeToPixScale ) # Quantizing
      pixWidth = pixRight - pixLeft # Fails to make uniform gaps in Chrome.

      blk = $(blk)
      blk.css( 'left', pixLeft + "px")
      blk.css( 'width', pixWidth - 2 + "px" )
      blk.children('.blockclip').width( Math.max(pixWidth-6,2) + "px" )

# end class ResourceUseTimeSpan


window.after_update = ->
  sched = $('#multi_sched_view'); return unless sched.length > 0

  window.grid ||= new ResourceSchedule( sched )

  sched.sortable({ axis: 'y', handle: '.rsrclabel', revert: true })

  window.grid.complete_data_request()

  setInterval (-> window.grid.update_check()), 30000


$( -> window.after_update() )

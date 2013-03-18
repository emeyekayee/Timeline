class @TimePix            # Ultimately, an angular $service
  constructor: -> null

  @baseTime: 0
  @timeWindow: (3 * 3600)
  @pixWindow: 750         # Matching width of #scrolling-container

  # Time range [@tlo..@thi] is where the DOM has data.
  @tlo: null
  @thi: null

  # Meta-data about most recent request
  @meta: {}

  @merge_metadata: (data) ->
    @meta = data.meta
    @baseTime ||= @meta['min_time']
    @tlo = @tlo && Math.min( @tlo, @meta.t1 ) || @meta.t1
    @thi = @thi && Math.max( @thi, @meta.t2 ) || @meta.t2
    @inc = @meta.inc

  @next_hi: -> @thi + @timeWindow
  @next_lo: -> @tlo - @timeWindow

  # Ignoring @baseTime offset
  @secs_to_pix_scale: (seconds) ->
    pix = seconds * @pixWindow / @timeWindow
    # Math.round(pix * 100) / 100

  @pix_to_secs: (pix) ->
    @baseTime + Math.round(pix * @timeWindow  / @pixWindow)

  @style_geo: (block) ->
    [s, e] = [block.starttime, block.endtime]             # per margins V
    "left: #{@secs_to_pix_scale(s - @baseTime)}px; " +
    "width: #{@secs_to_pix_scale(e-s)-4}px;" 
  
  @row_kind: (tag) ->  # may/may not belong here.
    tag.split('_')[0]




  @ux_time_now: ->
    new Date().valueOf() / 1000

  @ux_time_offset: (uxt) ->
    uxt - @baseTime

  @ux_time_offset_pix: (uxt) ->
    @secs_to_pix_scale @ux_time_offset(uxt)

  @scroll_to_ux_time: (uxt) ->
    sc = $('#scrolling-container')
    sc.scrollLeft( @ux_time_offset_pix(uxt) )

  @scroll_to_thi: ->
    @scroll_to_ux_time( @thi - @timeWindow )

  @ux_time_of_pix: (x) ->
    @pix_to_secs(x) 

  @scroll_to_tlo: =>   # bound
    @scroll_to_ux_time @tlo

  @set_time_cursor: => # bound
    cursor = $('#current-time-cursor')
    now_offset = @ux_time_offset_pix( @ux_time_now() );
    cursor.css( 'left',  now_offset + 'px' )
    setTimeout( @set_time_cursor, 15 * 1000 )



  @scroll_monitor: =>
    sc = $('#scrolling-container')
    if @scroll_monitor.old_scroll != sc.scrollLeft()
      @scroll_monitor.old_scroll = sc.scrollLeft()
      @scroll_monitor.scroll_timestamp = new Date()

      # Fetch more data if needed
      l_vis_time = @pix_to_secs sc.scrollLeft()
      r_vis_time = l_vis_time + @timeWindow

      if      r_vis_time > @thi
        RsrcListCtrlScope.$apply RsrcListCtrlScope.more_data
      else if l_vis_time < @tlo
        RsrcListCtrlScope.$apply RsrcListCtrlScope.less_data
    else
      if new Date() - @scroll_monitor.scroll_timestamp > 1000
        filter_justify_tweaks( sc ) # Try to make scrolled-off content visible
        @scroll_monitor.scroll_timestamp = new Date()

    setTimeout @scroll_monitor, 100


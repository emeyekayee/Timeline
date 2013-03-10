class @TimePix            # Ultimately, an angular $service
  constructor: -> null

  @baseTime: 0
  @timeWindow: (3 * 3600)

  # Time range [@tlo..@thi] is where the DOM has data.
  @tlo: null
  @thi: null

  # Meta-data about most recent request
  @meta: {}

  @merge_metadata: (data) ->
    @meta = data.meta
    TimePix.baseTime ||= (@meta['minTime'] - TimePix.timeWindow * 8)
    TimePix.tlo = TimePix.tlo && Math.min( TimePix.tlo, @meta.t1 ) || @meta.t1
    TimePix.thi = TimePix.thi && Math.max( TimePix.thi, @meta.t2 ) || @meta.t2
    @inc = @meta.inc




  @ux_time_now: ->
    new Date().valueOf() / 1000

  @ux_time_offset: (uxt) ->
    uxt - @baseTime

  @ux_time_offset_pix: (uxt) ->
    UseBlock.secs_to_pix_scale @ux_time_offset(uxt)

  @scroll_to_ux_time: (uxt) ->
    sc = $('#scrolling-container')
    sc.scrollLeft( @ux_time_offset_pix(uxt) )

  @scroll_to_thi: ->
    @scroll_to_ux_time( @thi - @timeWindow )

  @ux_time_of_pix: (x) ->
    UseBlock.pix_to_secs(x) 

  @scroll_to_tlo: =>   # bound
    @scroll_to_ux_time @tlo

  @set_time_cursor: => # bound
    cursor = $('#current-time-cursor')
    now_offset = @ux_time_offset_pix( @ux_time_now() );
    cursor.css( 'left',  now_offset + 'px' )
    setTimeout( @set_time_cursor, 15 * 1000 )



  @scroll_monitor: =>
    sc = $('#scrolling-container')
    l_vis_time = UseBlock.pix_to_secs sc.scrollLeft()
    r_vis_time = l_vis_time + @timeWindow

    if      r_vis_time > @thi
      RsrcListCtrlScope.$apply RsrcListCtrlScope.more_data
    else if l_vis_time < @tlo
      RsrcListCtrlScope.$apply RsrcListCtrlScope.less_data

    setTimeout @scroll_monitor, 100


class @TimePix            # Ultimately, an angular $service
  constructor: -> null

  @ux_time_now: ->
    new Date().valueOf() / 1000

  @ux_time_offset: (uxt) ->
    uxt - UseBlock.baseTime

  @ux_time_offset_pix: (uxt) ->
    UseBlock.secs_to_pix_scale @ux_time_offset(uxt)

  @scroll_to_ux_time: (uxt) ->
    sc = $('#scrolling-container')
    sc.scrollLeft( @ux_time_offset_pix(uxt) )

  @scroll_to_thi: ->
    @scroll_to_ux_time( UseBlock.thi - UseBlock.timeWindow )

  @ux_time_of_pix: (x) ->
    UseBlock.pix_to_secs(x) 

  @scroll_to_tlo: =>   # bound
    @scroll_to_ux_time UseBlock.tlo

  @set_time_cursor: => # bound
    cursor = $('#current-time-cursor')
    now_offset = @ux_time_offset_pix( @ux_time_now() );
    cursor.css( 'left',  now_offset + 'px' )
    setTimeout( @set_time_cursor, 15 * 1000 )



  @scroll_monitor: =>
    sc = $('#scrolling-container')
    l_vis_time = UseBlock.pix_to_secs sc.scrollLeft()
    r_vis_time = l_vis_time + UseBlock.timeWindow

    if  r_vis_time > UseBlock.thi
      RsrcListCtrlScope.$apply RsrcListCtrlScope.more_data
    else if l_vis_time < UseBlock.tlo
      RsrcListCtrlScope.$apply RsrcListCtrlScope.less_data

    setTimeout @scroll_monitor, 100


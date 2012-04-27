window.InfoPopup = {
  smidge: 5

  mouseOverOutHand: (evt) ->
    tt = $(evt.currentTarget).parents('.blockdiv').children('div.tt')
    InfoPopup.display( evt, tt ) if  tt.length == 1
    evt.stopPropagation()

  place: (tt, xoff, yoff) ->
    tt.css( 'top', yoff + "px")
    tt.css('left', xoff + "px")

  display: (evt, tt) ->
    if evt.type == 'mouseover'
      tt.fadeIn() # tt.show()
      [pX, pY] = [evt.pageX, evt.pageY]

      if pX <  innerWidth / 2 then xoff = pX + @smidge
      else                         xoff = pX - @smidge - tt.outerWidth()
      if pY < innerHeight / 2 then yoff = pY + @smidge
      else                         yoff = pY - @smidge - tt.outerHeight()

      @place(tt, xoff, yoff)
    else
      tt.fadeOut() # tt.hide()
}

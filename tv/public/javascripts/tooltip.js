var Tooltip = {
  EffectOptions: {},

  debug: false, // Typically set from grid.js[27]
  done: false,
  offset: 2,
  
  reset: function (element) {
    var effect = $(element)._effect;
    if(effect) effect.cancel();
  },

  refSides: [ $w('left right'), $w('top bottom') ],

  // WAS: getTooltip: function (elt) {return $('tt'+elt.id)},
  getTooltip: function (elt) {return elt.down('div.tt')},
  //
  // Experimental: Create on demand tooltip at 'top' level
  // getTooltip: function (elt) {
  //   var tt = $('tooltip');
  //   var t  = elt.down('div.tt')
  //   if ( !t )
  //     return;
  //   tt.innerHTML = t.innerHTML;
  //   return tt;
  // },

  xyAs01: function (o) {return [o.x || o.width, o.y || o.height]},
  
  getEvtPointer: function (evt) {return this.xyAs01(evt.pointer())},

  getViewportSize: function () {return this.xyAs01(
                                         document.viewport.getDimensions())},

  display: function (evt, eBlockdiv) {
    var over  =  evt.type == 'mouseover';
    var tt    =  this.getTooltip(eBlockdiv);
    if ( !tt || Tooltip.done ) return;                                 // XXXX

    var dbStr = over? 'mouseOVER:\n   ' : 'mouseOUT :\n   ';           // XXXX
    if (Tooltip.debug) {console.info( dbStr );}                        // XXXX
    
    var dvOffsets  = document.viewport.getScrollOffsets();
    var dl = tt.down('.detail_list');
    if (over) this.setStyles( 
                    tt,
                    dl,
                    this.getEvtPointer(evt).zip( dvOffsets,    // ptrVpLoc
                            function(a){return a[0] - a[1]} ),
                    this.getViewportSize() );                  // vptSize

     // Tooltip.reset(tt);          // Specific to use of effects.js
     // var options = over ? {to: 0.85, delay: 0.1, duration: 0.5 } : 
     //                      {to: 0.00, delay: 0.0, duration: 0.25};
     // tt._effect = new Effect[over ? 'Appear':'Fade'](tt, options);

     if (over) tt.show()      // Without effects.js
     else      tt.hide();
  },


  setStyles: function (tt, dl, ptrVpLoc, vptSize) {
    var dlStyle = $H();// WAS {top: '', bottom: '', left: '', right: ''}
    dl.style.top = dl.style.bottom = dl.style.left = dl.style.right = '';
    var ttStyle = $H();

    var dbStr = 'ptrVpLoc=' + ptrVpLoc + ',  vptSize=' + vptSize;      // XXXX

    var putLo = ptrVpLoc.zip( vptSize,    // put dl popup to left,top of ptr?
                  function(a) {return (a[0] > a[1]/2) ? 1 : 0} );

    dbStr    += '  putLo= ' + putLo.map( function(pL) {                // XXXX
                     return 'put' + (pL?'Lo':'Hi') }).join(', ');      // XXXX

    $w('left top').zip( ptrVpLoc, function(a) {
                   ttStyle[ a[0] ] = a[1]+'px' } );

    this.refSides.zip( putLo, function(a){ dlStyle[ a[0][a[1]] ] = '1px';
      dbStr += '  Setting dlStyle[ ' + a[0][a[1]] + ' ] = "1px"';      // XXXX
                                         } );
    dbStr += '\n' + 'ttStyle= ' + ttStyle + 
                 '   dlStyle= ' + dlStyle                              // XXXX

    tt.setStyle( ttStyle );               
    dl.setStyle( dlStyle ); 

    if (Tooltip.debug) {                                               // XXXX
      console.info( dbStr );                                           // XXXX
      // Tooltip.done = true;                                          // XXXX
      }                                                                // XXXX
  },
}

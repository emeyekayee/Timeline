var DragAmong = {
  active:   null,

  create: function(elts) {
    elts.each( function(elt) {
                 var da = new DragAlong(elt);
                 // Ensure ID!                                          XXXX  
                 this.these[elt.id] = da; 
               }.bind(this) 
              );
  },
};
DragAmong.these = $H(); //    []


var DragAlong = Class.create({
  trigger: 0.10,
  
  initialize: function( elt ){  // SHOULD have separate 'handle' elt or selector.
    this.element = elt = $(elt);
    this.handleMouseDown = this.mouseDownHandler.bind(this); // Do it below ??????
    //    WAS: elt.observe( 'mousedown', this.handleMouseDown );
    // RATHER: Use label-only as handle.
    elt.down('.rsrclabel').observe( 'mousedown', this.handleMouseDown );
  },


  mouseDownHandler: function(evt) {
    if (evt.element().up('.rsrcRow') != this.element) return;
    // Assert this in DragAmong.these &&
    //        this.previous(), this.next() (if exist) in DragAmong.these
    // SEE: Draggable.initDrag(): isLeftClick(), NO forms, valid-to-drag.
    
    this.handleMouseMove = this.mouseMoveHandler.bind(this);
    this.handleMouseUp   = this.mouseUpHandler.bind(this);
    // this.handleKeyPress   = this.keyPressHandler.bind(this);
    document.observe( 'mousemove', this.handleMouseMove );
    document.observe( 'mouseup', this.handleMouseUp );
    // document.observe( 'keypress', this.handleKeyPress );

    this.element.up('.multisched').style.cursor = 'move';

    this._orig_background = this.element.style.background;
    this.element.style.background = 'red';
    DragAmong.active = this;    // SEE: Draggables.activate()

    evt.stop();
  }, // RATHER: .bind(this), ???


  mouseMoveHandler: function(evt){
    // Assert this in DragAmong.these &&
    //        this.previous(), this.next() (if exist) in DragAmong.these
    // SEE: Draggable.initDrag(): isLeftClick(), NO forms, valid-to-drag.

    var pointer = [evt.pointerX(), evt.pointerY()];

    var next, prev;

    while (next = this.element.next()) {
      // ToDo: Check/establish pre-computed threshhold (?)
      Position.within( next, pointer[0], pointer[1] ); // CAN OSCILLATE ?
      if (Position.overlap('vertical', next) > 1 - this.trigger) break;    
      next.insert({after: this.element});
      // ToDo: Reset cached threshholds
    };

    while (prev = this.element.previous()) {
      // ToDo: Check/establish threshhold (?)
      Position.within( prev, pointer[0], pointer[1] );  
      if (Position.overlap('vertical', prev) < this.trigger) break;
      prev.insert({before: this.element});
      // ToDo: Reset cached threshholds
    };

    evt.stop();
    return;
  },


  mouseUpHandler: function(evt){

    // CLEANUP  
    document.stopObserving( 'mousemove', this.handleMouseMove );
    document.stopObserving( 'mouseup', this.handleMouseUp );
    // document.stopObserving( 'keypress', this.handleKeyPress );

    this.element.up('.multisched').style.cursor = 'auto';
    
    this.element.style.background = this._orig_background;
    DragAmong.active = null;    // SEE: Draggables.deactivate()

    evt.stop();
  },


//    keyPressHandler: function(evt){
//  
//    },


});

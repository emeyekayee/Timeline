# timelabel.rb
# Copyright (c) 2008-2011 Mike Cannon (http://github.com/emeyekayee/Timeline)
#                                     (michael.j.cannon@gmail.com)
#
# This is a bit of an experiment -- a single class that produces various
# kinds of resource use blocks.  Perhaps better as separate classes.
class Timelabel

  attr_accessor :starttime, :endtime
  attr_accessor :css_classes, :block_label

  @@labelFor = Hash.new{|h, k| ""}
  @@labelFor['hour']     = "Hour"
  @@labelFor['dayNight'] = "Day"
   

  @@formatFor = Hash.new{|h, k| ""}
  @@formatFor['hour']     = "%I:%M"
  @@formatFor['dayNight'] = '<span class="ampmLeft" > %P </span>' +
     '<span class="ampmCenter">&nbsp %a %B %d &nbsp&nbsp </span>' +
                            '<span class="ampmRight"> %P </span>' 
                                         
  def format; self.class.formatForVariant @v end

  @@t_blockFor =  Hash.new{|h, k| ""}
  @@t_blockFor['hour']     = 15.minutes
  @@t_blockFor['dayNight'] = 12.hours

  @@serial = 0

  private
  def self.labelForVariant( v )   @@labelFor[v]   end
  def self.formatForVariant( v )  @@formatFor[v]  end
  def self.t_blockForVariant( v ) @@t_blockFor[v] end
  public


  def initialize( variant, t )
    @v = variant

    self.block_label = t.strftime(self.class.formatForVariant @v).sub( /(^| )0/, '')
    ampm = if t.hour < 12; "am" else "pm" end
    self.css_classes = "timeblock #{@v}Timeblock #{ampm}Timeblock"

    s = e = t.to_i
    e += self.class.t_blockForVariant(@v).to_i

    self.starttime, self.endtime = [s, e].map{|i| i.to_s }
  end

  ################################################################
  # ScheduledResource protocol...
  #
  #
  # Builds a hash: { resourceId => list-of-blocks, ... }
  # The blocks are those in the time
  # interval <tt>t1..t2</tt> ordered by starttime.
  #
  def Timelabel.get_all_blocks(ids, t1, t2)
    ret = {}
    ids.each{ |id|
      ret[id] = get_timeblocks(id, t1, t2)
    }
    ret
  end


  # 
  def Timelabel.get_timeblocks(id, t1, t2)
    v = Timeheader.variantOfId id
    # v = 'dayNight'
    tb = t_blockForVariant v
    
    res = []

    t = t1
    if tb > 1.hour # Generalize this through :day, :month, :year  XXXX
      t = t1.change( :hour => 0 )
      until (t..(t + tb)) === t; t += tb end
    end

    while ( t < t2 ) do
      res.push( Timelabel.new(v, t) )
      t += tb
    end

    res
  end


end

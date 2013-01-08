# timelabel.rb
# Copyright (c) 2008-2012 Mike Cannon (http://github.com/emeyekayee/Timeline)
#                                     (michael.j.cannon@gmail.com)
# Abstract class, customized below for different kinds of time labels.

require 'timeheader'

class Timelabel
  attr_accessor :starttime, :endtime, :css_classes, :block_label

  class_attribute :label, :format, :t_block

  def initialize( t )
    @block_label = t.strftime(self.format).sub( /^0/, '' ).html_safe
    @css_classes = "timeblock #{t.strftime "%P"}Timeblock"
    @starttime, @endtime = [t, t+t_block].map{|t| t.to_i.to_s}
  end

  # (SchedResource protocol) Returns a hash where each key is an
  # <tt>rid</tt> and the value is an array of Timelabels (use
  # blocks) in the interval <tt>t1...t2</tt>, ordered by
  # <tt>starttime</tt>.
  #
  # What <em>in</em> means depends on *inc*.  If inc(remental) is 
  # false, client is building interval from scratch.  If "hi", it is
  # an addition to an existing interval on the high side.  Similarly
  # for "lo".  This is to avoid re-transmitting blocks that span the
  # current time boundaries on the client.
  #
  # Here the resource is a channel and the use blocks are programs.
  # 
  # ==== Parameters
  # * <tt>rids</tt> - A list of schedules resource ids (strings).
  # * <tt>t1</tt>   - Start time.
  # * <tt>t2</tt>   - End time.
  # * <tt>inc</tt>  - One of nil, "lo", "hi" (See above).
  #
  # ==== Returns
  # * <tt>Hash</tt> - Each key is a <tt>rid</tt> such as Hour0
  # and the value is an array of Timelabels in the interval, ordered by
  # <tt>starttime</tt>.
  def Timelabel.get_all_blocks(ids, t1, t2, inc)
    h = {}; ids.each{|id| h[id] = get_timeblocks(id, t1, t2, inc)}; h
  end

  def Timelabel.get_timeblocks(id, t1, t2, inc)
    klass = self
    it0, it2, itb = [klass.floor(t1), t2, klass.t_block].map(&:to_i)

    it0 += itb if inc == 'hi'
    it2 -= itb if inc == 'lo'

    it0.step(it2, itb).map{|i| klass.new(Time.at i)}
  end # Hmm... Seems like step should work for Time as well as for numbers.

  def Timelabel.floor(t) t; end
end



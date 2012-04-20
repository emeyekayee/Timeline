# timelabel.rb
# Copyright (c) 2008-2012 Mike Cannon (http://github.com/emeyekayee/Timeline)
#                                     (michael.j.cannon@gmail.com)
# Abstract class, customized below for different kinds of time labels.

require 'timeheader.rb'

class Timelabel
  attr_accessor :starttime, :endtime, :css_classes, :block_label

  class_attribute :label, :format, :t_block

  def initialize( t )
    @block_label = t.strftime(self.format).sub( /^0/, '' ).html_safe
    @css_classes = "timeblock #{t.strftime "%P"}Timeblock"
    @starttime, @endtime = [t, t+t_block].map{|t| t.to_i.to_s}
  end

  # ScheduledResource protocol...
  #   Builds a hash: { resourceId => list-of-blocks, ... }
  def Timelabel.get_all_blocks(ids, t1, t2, inc)
    # Hash[ ids.map{|id| [ id, get_timeblocks(id, t1, t2) ]}.flatten(1) ]
    h = {}; ids.each{|id| h[id] = get_timeblocks(id, t1, t2, inc)}; h
  end

  def Timelabel.get_timeblocks(id, t1, t2, inc)
    klass = Timeheader.label_subclass_for id 
    it0, it2, itb = [klass.floor(t1), t2, klass.t_block].map(&:to_i)

    it0 += itb if inc == 'hi'
    it2 -= itb if inc == 'lo'

    it0.step(it2, itb).map{|i| klass.new(Time.at i)}
  end # Hmm... Seems like step should work for Time as well as for numbers.

  def Timelabel.floor(t) t; end
end


class Timelabelhour < Timelabel
  self.label   = 'Hour'
  self.format  = '%I:%M'
  self.t_block = 15.minutes

  # def initialize( t )
  #   super
  #   @block_label = t.strftime(self.format).html_safe
  # end
end

class TimelabeldayNight < Timelabel
  self.label   = 'Day'
  self.format  = '<span class="ampmLeft" > %P </span>' +
                 '<span class="ampmCenter">&nbsp %a %B %d &nbsp&nbsp </span>' +
                 '<span class="ampmRight"> %P </span>'
  self.t_block = 12.hours

  def self.floor(t) t.change( :hour => (t.hour/12) * 12 ); end
end


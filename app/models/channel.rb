# channel.rb
# Copyright (c) 2008-2012 Mike Cannon (http://github.com/emeyekayee/Timeline)
# (michael.j.cannon@gmail.com)
class Channel < ActiveRecord::Base
  self.table_name  = "channel"
  self.primary_key = "chanid"
  has_many          :programs

  # channum is a String like "4" or "4_1"
  @@channel_by_num = {} 

  chs = all(:conditions => "visible")
  chs.each{ |ch| @@channel_by_num[ch.channum] = ch }


  # Methods for (SchedResource)

  def self.channel_by_num() @@channel_by_num end

  # (For SchedResource protocol)  Returns a Channel object from channum.  This
  # lets us specify the yml configuration with regular channel numbers rather
  # than funky database id integers.
  # 
  # ==== Parameters
  # * <tt>channum</tt> - A channel number (string) as we usually think of it
  #   rather than the chanid, the database id for this table.
  #
  # ==== Returns
  # * <tt>Channel</tt>
  def self.find_as_schedule_resource (rid)
    @@channel_by_num[rid] # rid is channum
  end

  # (For SchedResource protocol)  This method lets us set display attributes
  # on the instance in a resource-class-specific way.
  # 
  # ==== Parameters
  # * <tt>rsrc</tt> - A SchedResource instance. 
  def decorate_resource( rsrc )
    rsrc.label = self.channum
    rsrc.title = self.name
  end

end


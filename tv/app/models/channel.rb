# channel.rb
# Copyright (c) 2008-2011 Mike Cannon (http://github.com/emeyekayee/Timeline)
# (michael.j.cannon@gmail.com)
class Channel < ActiveRecord::Base
  set_table_name    "channel"
  set_primary_key   "chanid"
  has_many          :programs

  # channum is a String like "4" or "4_1"
  @@channel_by_num = {} 

  chs = find(:all, :conditions => "visible")
  chs.each{ |ch| @@channel_by_num[ch.channum] = ch }


  # Methods for (SchedResource)

  # Return Channel object from channum (String)
  def self.find_as_schedule_resource (rid)
    @@channel_by_num[rid] # rid is channid
  end

  def decorateResource( rsrc )
    rsrc.label = self.channum
    rsrc.title = self.name
  end

end


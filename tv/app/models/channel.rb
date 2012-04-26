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

  # Convenience
  def self.channel_by_num() @@channel_by_num end

  # Return Channel object from channum (String)
  def self.find_as_schedule_resource (rid)
    @@channel_by_num[rid] # rid is channum
  end

  def decorateResource( rsrc )
    rsrc.label = self.channum
    rsrc.title = self.name
  end

end


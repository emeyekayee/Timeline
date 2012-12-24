# timeheader.rb
# Copyright (c) 2008-2012 Mike Cannon (http://github.com/emeyekayee/Timeline)
#                                     (michael.j.cannon@gmail.com)
# This is a resource class (model) for time-based headers (rows in the schedule).
# Here and in timelabel.rb a resource id also determines subclasses.
# More on that below. See classes Timeheader, Timelabel.

require 'timelabel'

class Timeheader
  @@header_by_rid = {}

  def initialize( rid )
    @@header_by_rid[@rid = rid] = self
  end

  # For SchedResource
  # Return Timeheader* object from resource id (string)
  def self.find_as_schedule_resource( rid )
    @@header_by_rid[rid] || (@@header_by_rid[rid] = new(rid))
  end

  def decorate_resource( rsrc )
    klass = SchedResource.block_class_for_resource_name(self.class.name)
    rsrc.label = klass.label
    rsrc.title = @rid
  end

end  


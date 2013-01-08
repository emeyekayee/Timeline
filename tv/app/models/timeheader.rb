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

  # (SchedResource protocol)  Returns the corresponding Timeheader object 
  # given a resource id (string).  These rids (specified in schedule.yml) are
  # pretty much arbitrary as long as they are unique for this resource class.
  #
  # ==== Parameters
  # * <tt>rid</tt> - A (string) resource id.
  #
  # ==== Returns
  # * <tt>Timeheader</tt> - A Timeheader corresponding to the given <tt>rid</tt>,
  #   such as 'Hour0'.
  def self.find_as_schedule_resource( rid )
    @@header_by_rid[rid] || (@@header_by_rid[rid] = new(rid))
  end

  # (For SchedResource protocol)  This method lets us set display attributes
  # on the instance in a resource-class-specific way.
  # 
  # ==== Parameters
  # * <tt>rsrc</tt> - A SchedResource instance. 
  def decorate_resource( rsrc )
    klass = SchedResource.block_class_for_resource_name(self.class.name)
    rsrc.label = klass.label
    rsrc.title = @rid
  end

end  


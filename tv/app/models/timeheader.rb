# timeheader.rb
# Copyright (c) 2008-2012 Mike Cannon (http://github.com/emeyekayee/Timeline)
#                                     (michael.j.cannon@gmail.com)
# This is a resource class (model) for time-based headers (rows in the schedule).
# Here and in timelabel.rb a resource id also determines subclasses.
# More on that below. See classes Timeheader, Timelabel.

require 'timelabel'

class Timeheader
  
  # The id here, e.g. "hour0", is an alpha string like "hour" or
  # "dayNight" (the variant), indicating subclasses of Timelabel.
  # It is followed by non-alpha and other uniquifying chars
  def self.variantOfId( rid ); rid =~ /^[a-zA-Z]+/; $& end

  def self.label_subclass_for(rid) eval "Timelabel#{variantOfId(rid)}" end

  @@header_by_rid = Hash.new{ |hash, key| # key is rid 
                              hash[key] = self.new( key )
                             }

  # For SchedResource
  # Return Timeheader object from resource id (string)
  def self.find_as_schedule_resource(rid)  @@header_by_rid[rid]  end

  def initialize( rid ) @rid = rid end

  # For SchedResource
  def decorateResource( rsrc )
    rsrc.label = Timeheader.label_subclass_for( @rid ).label
    rsrc.title = @rid
  end

end  

class TimeheaderdayNight < Timeheader
end

class Timeheaderhour < Timeheader
end


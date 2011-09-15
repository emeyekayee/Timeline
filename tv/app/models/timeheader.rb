# timeheader.rb
# Copyright (c) 2008-2011 Mike Cannon (http://github.com/emeyekayee/Timeline)
#                                     (michael.j.cannon@gmail.com)
# This is a resource class for time-based headers.  Neither this or
# the resource use class Timelabel use ActiveRecord.  There are some
# games played with the resource id here too.  More on that later.
# See class Timeheader

require 'timelabel'

class Timeheader

  # has_many   :timelabels (wink)

  @@header_by_id = Hash.new{ |hash, key|  
                     hash[key] = self.new( key )
                     }

  # The id here is a String like "hour" or "dayNight" (variants of Timelabel)
  # followed by non-alpha +other uniquifying chars eg: "hour0"
  def self.variantOfId( id ); id =~ /^[a-zA-Z]+/; $& end

  def initialize( id )
    @id = id
    @variant = self.class.variantOfId id
  end


  # Methods for SchedResource

  # Return Timelabel object from resource id (String)
  def self.find_as_schedule_resource (rid)
    @@header_by_id[rid]
  end

  def decorateResource( rsrc )
    rsrc.label = Timelabel.labelForVariant( @variant )
    rsrc.title = @id
  end

end  

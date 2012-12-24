# sched_resource.rb  
# Copyright (c) 2008-2012 Mike Cannon (http://github.com/emeyekayee/Timeline)
# (michael.j.cannon@gmail.com)
# See class SchedResource.

require 'timelabel.rb'
require 'timeheader.rb'

# A "schedule resource" is something that can be used for one thing at a time.
#
# Example: A Room (resource) is scheduled for a meeting (resource use block)
# titled "Weekly Staff Meeting" tomorrow from 9am to 11am.
# A mouse click on the block pops up the "owner" and other
# information about the meeting.
#
# Class SchedResource manages class names, id's and labels for a 
# schedule.  An instance ties together:
# 
# 1) a <em>resource</em> class (eg Room),  
# 2) an id, and
# 3) a few strings / html snippets (eg, label, title) for the DOM
#
# The id (2 above) is used to
#
# a) select a resource <em>instance</em> and
# 
# b) select instances of the <em>resource use block</em> class (eg Meeting).
# 
# The id <em>may</em> be a database id but need not be.
# It is used <em>only</em> by class methods
# <tt>Resource.find_as_schedule_resource</tt> and
# <tt>ResourceUseBlock.get_all_blocks</tt>.
#
# Not tying this to a database id
# allows a little extra flexibility and simple optimization.
#
# Items 1 and 2 are are combined (with a '_') to form a "tag" for the DOM.
#
# See also:              ResourceUseBlock (below).
#
class SchedResource
 
  @@config = nil              

  # @@config is loaded from config/schedule.yml.
  #  all_resources               Resources in display order
  #  rsrcs_by_kind               Resources (above) grouped by kind (a hash)
  #  rsrc_of_tag                 Indexed by text tag: kind_subId
  #  visibleTime                 Span of time window.
  #  blockClassForResourceKind   
  #
  # When queried with an array of ids and a time interval, the class
  # method <tt>get_all_blocks(ids, t1, t2)</tt> of a <em>resource use</em>
  # model returns a list of "use blocks", each with a starttime, endtime
  # and descriptions of that use.
  # 
  # This method invokes invokes that method on each of the <em>resource use<em>
  # classes.  It return a hash where:
  #   Key is a Resource (rsrc);
  #   Value is an array of use-block instances.
  # 
  def self.get_all_blocks(t1, t2, inc)
    blockss = {}

    @@config[:rsrcs_by_kind].each{ |kind, rsrcs|
      rubClass =  block_class_for_resource_name( kind )
      ruBlks = rubClass.get_all_blocks( rsrcs.map{|r| r.subId}, t1, t2, inc )

      ruBlks.each { |rid, blks|
        rsrc = getFor( kind, rid )
        blockss[ rsrc ] = blks.map{ |blk| ResourceUseBlock.new( rsrc, blk ) }
      }
    }

    blockss
  end

  def self.block_class_for_resource_name( name )
    @@config[:blockClassForResourceKind][name]
  end


  # A caching one-of-each-sort constructor.
  # - kind: string (a class name)
  # - subId: string id, selecting a resource instance
  # The two are combined and used as a unique tag -- as a
  #  - DOM id/class on the client and
  #  - In server code.
  #
  def self.getFor( kind, subId )
    tag = composeTag( kind, subId )
    @@config[:rsrc_of_tag][ tag ] || self.new( kind, subId )
  end

  def self.config; @@config end
  
  def self.resourceList; @@config[:all_resources] end

  def self.visibleTime;  @@config[:visibleTime] end



  # Instance methods

  def kind()    @tag.sub( /_.*/, '' )          end
  def subId()   @tag.sub( /.*_/, '' )          end 
  def to_s()    @tag end
  def inspect() "<#SchedResource \"#{@tag}\">" end

  attr_accessor :label, :title
  def label();     @label || @tag end
  def title();     @title || @tag end

  def css_classes_for_row(); "rsrcRow #{self.kind}row #{@tag}row" end

  def self.makeResourceOfKind( klass, rid )
    klass = eval klass if klass.class == String
    getFor( klass.name, rid )
  end


  # Restore configuration from session.
  #
  # OK, Ok, this would not be RESTful if we were actually maintaining any
  # state here.  But if there <em>were</em> such state it would likely be
  # kept, eg, in a per-user table in the database.
  #
  def self.ensureConfig( session )
    return if (@@config ||= session[:scheduleConfig])

    SchedResource.configFromYaml( session )
  end


  # Process configuration file.
  def self.configFromYaml( session )
    configFromYaml1
    configFromYaml2 session 
    @@config
  end
    

  def self.configFromYaml1()
    @@config = { visibleTime: nil, rsrcs_by_kind: nil, all_resources: [] }
    @@config[:rsrc_of_tag]   = {}
    @@config[:blockClassForResourceKind] = {} 

    yml = YAML.load_file("config/schedule.yml")

    yml['ResourceKinds'].each{ |key, val|  # {"Channel" => <#Class Program>... }
      @@config[:blockClassForResourceKind][key] = eval val
    }

    if (rkls = yml['Resources'])        # Resource Kind Lists, eg
      rkls.each{ |rkl|                  # ["Timeheaderhour", "Hour0"]
        rkl = rkl.split(/[, ]+/)        # ["Channel",    "702", "703",... ]
        rk  = rkl.shift
        @@config[:all_resources] += rkl.map{|subId| makeResourceOfKind(rk, subId) }
      }
    end

    @@config[:visibleTime] = (vt = yml['visibleTime']) ? (eval vt) : 3.hours
    @@config
  end


  def self.configFromYaml2( session )
    @@config[:rsrcs_by_kind] = resourceList.group_by{ |r| r.kind }

    @@config[:rsrcs_by_kind].each do |kind, rsrcs|
      klass = eval kind
      rsrcs.each { |rsrc|
        klass.find_as_schedule_resource(rsrc.subId).decorateResource rsrc
      }
    end

    session[:scheduleConfig] = @@config
  end


  def self.composeTag( kind, subId ); "#{kind}_#{subId}" end


  def initialize( kind, subId )
    
    @tag = self.class.composeTag( kind, subId )  # WAS: rsrc
    @label = @title = nil
    @@config[:rsrc_of_tag][@tag] = self
  end


end # class SchedResource



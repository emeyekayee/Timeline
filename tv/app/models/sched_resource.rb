# sched_resource.rb
# Copyright (c) 2008-2012 Mike Cannon (http://github.com/emeyekayee/Timeline)
# (michael.j.cannon@gmail.com)
# See class SchedResource.

require 'timelabel'
require 'timeheader'

# A "scheduled resource" is something that can be used for one thing at a time.
#
# Example: A Room (resource) is scheduled for a meeting (resource use block)
# titled "Weekly Staff Meeting" tomorrow from 9am to 11am.
#
# Class SchedResource manages class names, id's and labels for a
# schedule.  An instance ties together:
#
#  1. A resource class (eg Room),
#  2. An id, and
#  3. Strings / html snippets (eg, label, title) for the DOM.
#
# The id (2 above) is used to
#
# a) select a resource <em>instance</em> and
#
# b) select instances of the <em>resource use block</em> class (eg Meeting).
#
# The id <em>may</em> be a database id but need not be.
# It is used by model class methods
# <tt>Resource.find_as_schedule_resource</tt> and
# <tt>ResourceUseBlock.get_all_blocks</tt>.
# Not tying this to a database id allows a little extra flexibility in
# configuration.
#
# Items 1 and 2 are are combined (with a '_') to form "tags" (ids) for the DOM.
#
# See also:              ResourceUseBlock.
#
#--
# Config is loaded from config/schedule.yml:
# all_resources::      Resources in display order.
# rsrcs_by_kind::      A hash with resources grouped by kind (resource class).
# rsrc_of_tag::        Indexed by text tag: kind_subid.
# \visible_time::       Span of time window.
#++
#
# When queried with an array of ids and a time interval, the class
# method <tt>get_all_blocks(ids, t1, t2)</tt> of a <em>resource use</em>
# model returns a list of "use blocks", each with a starttime, endtime
# and descriptions of that use.
#
# This method invokes that method on each of the <em>resource use</em>
# classes.  It returns a hash where:
#   Key     is a Resource (rsrc);
#   Value   is an array of use-block instances (rubs).
#
class SchedResource

  class_attribute :config

  # (SchedResource protocol) Returns a hash where each key is an
  # <tt>rid</tt> and the value is an array of resource use
  # blocks in the interval <tt>t1...t2</tt>, ordered by
  # <tt>starttime</tt>.
  #
  # What <em>in</em> means depends on <em>inc</em>.  If inc(remental) is 
  # false, the client is building the interval from scratch.  If "hi", it is
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
  # * <tt>Hash</tt> - Each key is an <tt>rid</tt> and the value is an array of resource use blocks in the interval, ordered by <tt>starttime</tt>.
  def self.get_all_blocks(t1, t2, inc)
    blockss = {}

    config[:rsrcs_by_kind].each do |kind, rsrcs|
      rub_class = block_class_for_resource_name kind
      rids      = rsrcs.map{ |r| r.sub_id }
      ru_blkss  = rub_class.get_all_blocks rids, t1, t2, inc

      add_rubs_of_kind kind, ru_blkss, blockss
    end

    blockss
  end

  
  # ==== Parameters
  # * <tt>name</tt>  - The class name (string) of a schedule resource.
  #
  # ==== Returns
  # * <tt>Class</tt> - The class representing the <em>use</em> of that resource for an interval of time.
  def self.block_class_for_resource_name( name )
    config[:block_class_for_resource_kind][name]
  end


  # ==== Returns
  # * <tt>Array[SchedResource]</tt> - List of all configured SchedResources .
  def self.resource_list; config[:all_resources] end

  # ==== Returns
  # * <tt>Time</tt> - The configured width of the visible time window.
  def self.visible_time;  config[:visible_time] end


  #--
  # Restore configuration from session.
  #
  # OK, Ok, this would not be RESTful if we were actually maintaining any
  # state here -- it's just a cache.  If there <em>were</em> such state it
  # would likely be kept, eg, in a per-user table in the database.
  #++
  def self.ensure_config( session ) # :nodoc:
    return if (self.config ||= session[:schedule_config])

    SchedResource.config_from_yaml( session )
  end


  # Process configuration file.
  def self.config_from_yaml( session )
    config_from_yaml1
    config_from_yaml2 session
    config
  end


  private
  # A caching one-of-each-sort constructor.
  #
  # ==== Parameters
  # * <tt>kind</tt>   - Class name (string) of a scheduled resource.
  # * <tt>sub_id</tt> - Id (string), selecting a resource instance.  The two are combined and used as a unique tag in the DOM as id and class attributes as well as in server code.
  def self.get_for( kind, sub_id )
    tag = compose_tag( kind, sub_id )
    config[:rsrc_of_tag][ tag ] || self.new( kind, sub_id )
  end

  def self.compose_tag( kind, sub_id ); "#{kind}_#{sub_id}" end

  def self.config_from_yaml1()
    self.config = { all_resources: [],
                    rsrc_of_tag: {}, 
                    block_class_for_resource_kind: {}
                   }
    yml = YAML.load_file "config/schedule.yml"

    yml['ResourceKinds'].each do |key, val| # {"Channel" => <#Class Program>...}
      config[:block_class_for_resource_kind][key] = eval val
    end

    if (rkls = yml['Resources'])        # Resource Kind Lists, eg
      rkls.each do |rkl|                # ["TimeheaderHour", "Hour0"]
        rkl = rkl.split(/[, ]+/)        # ["Channel",    "702", "703",... ]
        rk  = rkl.shift
        config[:all_resources] += rkl.map do |sub_id|
          make_resource_of_kind(rk, sub_id)
        end
      end
    end

    config[:visible_time] = (vt = yml['visibleTime']) ? (eval vt) : 3.hours
    config
  end


  def self.config_from_yaml2( session )
    config[:rsrcs_by_kind] = resource_list.group_by{ |r| r.kind }

    config[:rsrcs_by_kind].each do |kind, rsrcs|
      klass = eval kind
      rsrcs.each do |rsrc|
        klass.find_as_schedule_resource(rsrc.sub_id).decorate_resource rsrc
      end
    end

    session[:schedule_config] = config
  end

  def self.make_resource_of_kind( klass, rid )
    klass = eval klass if klass.class == String
    get_for( klass.name, rid )
  end

  def self.add_rubs_of_kind( kind, ru_blkss, blockss )
    ru_blkss.each do |rid, blks|
      rsrc = get_for( kind, rid )
      rubs = blks.map{ |blk| ResourceUseBlock.new rsrc, blk }
      blockss[ rsrc ] = rubs
    end
  end


  public

  # Instance methods
  def initialize( kind, sub_id ) # :nodoc:
    @tag = self.class.send( :compose_tag, kind, sub_id )
    @label = @title = nil
    config[:rsrc_of_tag][@tag] = self
  end

  # ==== Returns
  # * <tt>String</tt> - The class name of the scheduled resource.
  def kind()    @tag.sub( /_.*/, '' )          end

  # ==== Returns
  # * <tt>String</tt> - The <tt>rid</tt> (abstract id) of the SchedResource.
  def sub_id()  @tag.sub( /.*_/, '' )          end

  def to_s() # :nodoc:
    @tag
  end 

  def inspect() # :nodoc:
    "<#SchedResource \"#{@tag}\">"
  end 

  attr_accessor :label, :title
  def label();     @label || @tag end
  def title();     @title || @tag end

  # ==== Returns
  # * <tt>String</tt> - CSS classes automatically generated for the DOM row representing this SchedResource.
  def css_classes_for_row(); "rsrcRow #{self.kind}row #{@tag}row" end

end # class SchedResource



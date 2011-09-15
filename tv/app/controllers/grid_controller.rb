# grid_controller.rb
# Copyright (c) 2008-2011 Mike Cannon (http://github.com/emeyekayee/Timeline)
#                                     (michael.j.cannon@gmail.com)

require File.dirname(__FILE__) + '/application'

class GridController < ApplicationController
  # Nothing destructive here anyway...
  # protect_from_forgery :only => [:create, :update, :destroy]

  def index
    show
    render :action => 'show'
  end


  def show
    msg = if params[:reset]; :configFromYaml; else :ensureConfig end
    SchedResource.send( msg, session, logger )
    
    tNow = (Time.now + 5.minutes)
    tNow = tNow.change( :min => (tNow.min/15) * 15 )
    @t1 = params[:t1] || tNow
    @t2 = params[:t2] || @t1 + SchedResource.visibleTime
    @inc= params[:inc]

    get_data_for_time_span
  end


  def groupupdate
    # RATHER: Combine these into ensureConfig XXXX
    SchedResource.configFromYaml session, logger   if params[:reset]
    SchedResource.ensureConfig   session, logger

    @t1 = params[:t1] 
    @t2 = params[:t2] 
    @inc= params[:inc]
    get_data_for_time_span
  end


  def reorder
    logger.info( params[:order] )
  end


  # Set up instance variables for render templates
  #  params:  @t1:      time-inverval start
  #           @t2:      time-inverval end
  #           @inc:     incremental update?  One of: nil, "lo", "hi"
  #
  #  creates: @rsrcs    ordered resource list
  #           @blockss: lists of use-blocks, keyed by resource
  def get_data_for_time_span()

    @t1 = Time.at(@t1.to_i)  # Huh?  XXXX
    @t2 = Time.at(@t2.to_i)  # Huh?  XXXX

    @rsrcs = SchedResource.resourceList

    # logger.info "SchedResource.resourceList: "
    # @rsrcs.each{|r| logger.info "        #{r.to_s}"}

    @blockss = SchedResource.get_all_blocks(@t1, @t2, @inc, logger)

    # logger.info "GridController: #{@blockss.length}"
  end

end



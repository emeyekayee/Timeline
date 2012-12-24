class ScheduleController < ApplicationController
  def index
    schedule
    render :action => 'schedule'
  end

  def show
    schedule
    render :action => 'schedule'
  end

  def test
    SchedResource.config_from_yaml session
    @text = ""
    config = SchedResource.config
    config.keys.each{|key| @text << "\n#{key}:\n" + config[key].inspect}
  end

  def schedule
    SchedResource.send( params[:reset] ? :config_from_yaml : :ensure_config,
                        session )
                        
    tNow = (Time.now + 5.minutes)
    tNow = tNow.change( :min => (tNow.min/15) * 15 )
    @t1 = params[:t1] || tNow
    @t2 = params[:t2] || @t1 + SchedResource.visible_time
    @inc= params[:inc]

    get_data_for_time_span
  end

  def groupupdate
    SchedResource.ensure_config session

    @t1 = params[:t1]
    @t2 = params[:t2]
    @inc= params[:inc]
    get_data_for_time_span
  end


  private
  
  # Set up instance variables for render templates
  #  params:  @t1:      time-inverval start
  #           @t2:      time-inverval end
  #           @inc:     incremental update?  One of: nil, "lo", "hi"
  #
  #  creates: @rsrcs    ordered resource list
  #           @blockss: lists of use-blocks, keyed by resource
  def get_data_for_time_span()

    @t1 = Time.at(@t1.to_i)
    @t2 = Time.at(@t2.to_i)

    @rsrcs = SchedResource.resource_list

    @blockss = SchedResource.get_all_blocks(@t1, @t2, @inc)
  end


end

class ScheduleController < ApplicationController
  def index
  end

  def show
    schedule
    render :action => 'schedule'
  end

  def schedule
    meth = params[:reset] ? :config_from_yaml : :ensure_config
    SchedResource.send( meth, session )
    # SchedResource.config_from_yaml if params[:reset]
    # SchedResource.ensure_config session
    # 
    param_defaults params

    Rails.logger.debug "\n@t1= #{hm_ampm(@t1)}  @t2= #{hm_ampm(@t2)}\n"

    get_data_for_time_span
    respond_to do |format|
      format.html
      format.json do

        minTime = 2 ** 31
        @blockss.each do |rsrc, blocks|
          blocks.each do |block|
            block.starttime =  block.starttime.to_i
            block.endtime   =  block.endtime.to_i
            minTime = block.starttime if block.starttime < minTime
          end
        end
        @blockss['meta'] = {
          rsrcs: @rsrcs, minTime: minTime, 
          t1: @t1.to_i, t2: @t2.to_i, inc: @inc,
        }
        render json: @blockss
      end
    end
  end

  def groupupdate
    SchedResource.ensure_config session

    param_defaults params
    get_data_for_time_span
    respond_to do |format|
      format.html
      format.json { render json: @blockss }
    end
  end

  def test
    SchedResource.config_from_yaml session
    @text = ""
    config = SchedResource.config
    config.keys.each{|key| @text << "\n#{key}:\n" + config[key].inspect}
  end

  
  private
  
  # HH:MMam(pm)
  def hm_ampm(t)
    t = Time.at(t) if t.kind_of? Numeric
    Time.at(t).strftime("%I:%M%p").downcase.sub(/^0/,'')
  end
  
  def param_defaults(p = {})
    @t1 = p[:t1] || time_default
    @t2 = p[:t2] || @t1 + SchedResource.visible_time
    @inc= p[:inc]
  end

  def time_default
    z_offset = ActiveSupport::TimeZone['Pacific Time (US & Canada)'].utc_offset - 
               Time.now.utc_offset   # Typically, for deployment to UTC server 

    t_now = Time.now + z_offset
    t_now.change :min => (t_now.min/15) * 15
  end

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

# program.rb
# Copyright (c) 2008-2012 Mike Cannon (http://github.com/emeyekayee/Timeline)
# (michael.j.cannon@gmail.com)

class Program < ActiveRecord::Base
  self.table_name = "program"

  belongs_to        :channel,
                    :class_name   => "Channel",
                    :foreign_key  => "chanid" 

  attr_accessor     :css_classes, :block_label, :detail_list

  @@program_attrs = %w(
    chanid title subtitle description starttime endtime 
    category category_type stars airdate previouslyshown).join(', ')
  

  # (SchedResource protocol) Returns a hash where each key is a
  # resource id (channel number) and the value is an array of
  # Programs in the interval <tt>t1...t2</tt>, ordered by
  # <tt>starttime</tt>.
  #
  # What <em>in</em> means depends on *inc*.  If inc(remental) is 
  # false, client is building interval from scratch.  If "hi", it is
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
  # * <tt>inc</tt>  - One of nil, "lo", "hi" (As above).
  #
  # ==== Returns
  # * <tt>Hash</tt> - Each key is a <tt>rid</tt> (here, channel number)
  # and the value is an array of Programs in the interval, ordered by
  # <tt>starttime</tt>.
  def Program.get_all_blocks( rids, t1, t2, inc )
    chanids = rids.map{ |rid| Channel.find_as_schedule_resource(rid).chanid }
    
    condlo = "(endtime) > "
    condlo = "(starttime) >=" if inc == 'hi'
    
    condhi = "(starttime) <"
    condhi = "(endtime) <=" if inc == 'lo'

    conds = [ "(chanid IN (?))             AND " +
              "(UNIX_TIMESTAMP#{condlo} ?) AND " +
              "(UNIX_TIMESTAMP#{condhi} ?)",
              chanids,
              t1.to_i,
              t2.to_i ]

    rel1 = includes(:channel).select(@@program_attrs).order("chanid MOD 1000, starttime")
    blks = rel1.where(conds).each{ |pgm| pgm.set_visual_info }

    blks.group_by { |pgm| pgm.channel.channum }
  end

  # Calculate css classes for program block display using...
  #   - prog.category_type (eg, "series", ...)
  #   - prog.category      (eg, "news", "howto", ...)
  #
  # After .../mythweb/includes/css.php  v.18.1
  def set_visual_info ()
    set_style_classes
    set_block_label
  end

  private

  def set_block_label
    label = self.title
    label += ":<br/>&nbsp;#{self.subtitle}" if self.subtitle.length > 0
    self.block_label = label.html_safe
  end

  def set_style_classes()
    self.css_classes = ct_name + " " + to_css_class(self.category)
  end

  def ct_name
    ct = self.category_type || ''
    return '' if ct =~ /unknown/i
    "type_#{ct.gsub(/[^a-z0-9\-_]+/i, '_')}"
  end

  def to_css_class ( cat, clss = nil )
    return clss if (clss = @@css_translation_cache[ cat ])
    @@css_translation_cache[ cat ] = css_class_search(cat) 
  end

  def css_class_search ( cat )
    @@Categories.each do |key, val|
      return ('cat_' + key) if val =~ cat
    end
    'cat_Unknown' 
  end

  
  @@css_translation_cache = {}

#  @@Categories is a hash of keys
#  corresponding to the css style used for each show category.  Each
#  entry is an array containing the name of that category in the
#  language this file defines (it will not be translated separately),
#  and a regular expression pattern used to match the category against
#  those provided in the listings.
  @@Categories = {
    'Action'         =>  /\b(action|adven)/i,
    'Adult'          =>  /\b(adult|erot)/i,
    'Animals'        =>  /\b(animal|tiere)/i,
    'Art_Music'      =>  /\b(art|dance|music|cultur)/i,
    'Business'       =>  /\b(biz|busine)/i,
    'Children'       =>  /\b(child|infan|animation)/i,
    'Comedy'         =>  /\b(comed|entertain|sitcom)/i,
    'Crime_Mystery'  =>  /\b(crim|myster)/i,
    'Documentary'    =>  /\b(doc)/i,
    'Drama'          =>  /\b(drama)/i,
    'Educational'    =>  /\b(edu|interests)/i,
    'Food'           =>  /\b(food|cook|drink)/i,
    'Game'           =>  /\b(game)/i,
    'Health_Medical' =>  /\b(health|medic)/i,
    'History'        =>  /\b(hist)/i,
    'Horror'         =>  /\b(horror)/i,
    'HowTo'          =>  /\b(how|home|house|garden)/i,
    'Misc'           =>  /\b(special|variety|info|collect)/i,
    'News'           =>  /\b(news|current)/i,
    'Reality'        =>  /\b(reality)/i,
    'Romance'        =>  /\b(romance)/i,
    'SciFi_Fantasy'  =>  /\b(fantasy|sci\\w*\\W*fi)/i,
    'Science_Nature' =>  /\b(science|nature|environm)/i,
    'Shopping'       =>  /\b(shop)/i,
    'Soaps'          =>  /\b(soaps)/i,
    'Spiritual'      =>  /\b(spirit|relig)/i,
    'Sports'         =>  /\b(sport)/i,
    'Talk'           =>  /\b(talk)/i,
    'Travel'         =>  /\b(travel)/i,
    'War'            =>  /\b(war)/i,
    'Western'        =>  /\b(west)/i
  }

end



# program.rb
# Copyright (c) 2008-2011 Mike Cannon (http://github.com/emeyekayee/Timeline)
# (michael.j.cannon@gmail.com)

class Program < ActiveRecord::Base
  set_table_name    "program"
  
  belongs_to        :channel,
                    :class_name   => "Channel",
                    :foreign_key  => "chanid" 

  attr_accessor     :css_classes, :block_label, :detail_list

  @@program_attrs = %w(
    chanid title subtitle description starttime endtime 
    category category_type stars airdate previouslyshown).join(', ')

  # Returns a hash where each key is a <tt>SchedResource</tt> object
  # corresponding to a resource id and the value is an array of
  # blocks in the interval <tt>t1...t2</tt>, ordered by
  # <tt>starttime</tt>.
  #
  # Here the resource is a channel and the blocks are programs.
  # 
  def Program.get_all_blocks( rIds, t1, t2 )
    chanids = rIds.map{ |rId| Channel.find_as_schedule_resource(rId).chanid }
    
    conds = [ "(endtime   > ?) AND " +
              "(starttime < ?) AND " +
              "(chanid IN (?))",
              t1,
              t2,
              chanids ] 

    opts = { :select => @@program_attrs, :conditions => conds, 
             :order => "chanid MOD 1000, starttime"}
    
    blks = Program.all(opts).each{ |pgm| pgm.set_visual_info }

    blks.group_by { |pgm| pgm.channel.channum }
  end

  # Slightly faster, as program blocks are already ordered:
  #      ...
  #      blockss = {}
  #      Program.programs_by_channel( blks ) do |pgms|
  #        blockss[ pgms[0].chanid ] = pgms
  #      end 
  #      return blockss
  #
  #    # Group adjacent programs with same chanid and yield them.
  #    def Program.programs_by_channel( programs )
  #      until programs.empty? do
  #        v0 = programs[0].chanid
  #        bof = []
  #        
  #        until programs.empty? || v0 != programs[0].chanid do
  #          bof.push programs.shift
  #        end
  #        
  #        yield bof
  #      end
  #    end
  #


  # Figure css classes for program block display using...
  #   - prog.category_type (eg, "series", ...)
  #   - prog.category      (eg, "news", "howto", ...)
  #
  # After .../mythweb/includes/css.php  v.18.1
  def set_visual_info ()
    classes = ''

    ct = self.category_type
    ct  &&  ct !~ /unknown/i  &&
      classes << " type_" + ct.gsub( /[^a-zA-Z0-9\-_]+/, '_' )

    classes << " " + to_css_class(self.category)

    self.css_classes = classes
    self.block_label = "#{self.title}:<br/>&nbsp;#{self.subtitle}"
  end



protected

  def to_css_class ( cat )
    clss = @@css_translation_cache[ cat ]
    if ! clss
      @@Categories.each { |key, val|
        if (re = val[1]) && re =~ cat
          clss = @@css_translation_cache[ cat ] = 'cat_' + key
          break
        end
      }

      if ! clss: clss = @@css_translation_cache[ cat ] = 'cat_Unknown' end
    end
    
    clss
  end

  
  @@css_translation_cache = {}


#  @@Categories is a hash of keys
#  corresponding to the css style used for each show category.  Each
#  entry is an array containing the name of that category in the
#  language this file defines (it will not be translated separately),
#  and a regular expression pattern used to match the category against
#  those provided in the listings.
#
  @@Categories = {
    'Action'         =>  ['Action',           /\b(action|adven)/i],
    'Adult'          =>  ['Adult',            /\b(adult|erot)/i],
    'Animals'        =>  ['Animals',          /\b(animal|tiere)/i],
    'Art_Music'      =>  ['Art_Music',        /\b(art|dance|music|cultur)/i],
    'Business'       =>  ['Business',         /\b(biz|busine)/i],
    'Children'       =>  ['Children',         /\b(child|infan|animation)/i],
    'Comedy'         =>  ['Comedy',           /\b(comed|entertain|sitcom)/i],
    'Crime_Mystery'  =>  ['Crime / Mystery',  /\b(crim|myster)/i],
    'Documentary'    =>  ['Documentary',      /\b(doc)/i],
    'Drama'          =>  ['Drama',            /\b(drama)/i],
    'Educational'    =>  ['Educational',      /\b(edu|interests)/i],
    'Food'           =>  ['Food',             /\b(food|cook|drink)/i],
    'Game'           =>  ['Game',             /\b(game)/i],
    'Health_Medical' =>  ['Health / Medical', /\b(health|medic)/i],
    'History'        =>  ['History',          /\b(hist)/i],
    'Horror'         =>  ['Horror',           /\b(horror)/i],
    'HowTo'          =>  ['HowTo',            /\b(how|home|house|garden)/i],
    'Misc'           =>  ['Misc',        /\b(special|variety|info|collect)/i],
    'News'           =>  ['News',             /\b(news|current)/i],
    'Reality'        =>  ['Reality',          /\b(reality)/i],
    'Romance'        =>  ['Romance',          /\b(romance)/i],
    'SciFi_Fantasy'  =>  ['SciFi / Fantasy',  /\b(fantasy|sci\\w*\\W*fi)/i],
    'Science_Nature'=> ['Science / Nature',/\b(science|nature|environment)/i],
    'Shopping'       =>  ['Shopping',         /\b(shop)/i],
    'Soaps'          =>  ['Soaps',            /\b(soaps)/i],
    'Spiritual'      =>  ['Spiritual',        /\b(spirit|relig)/i],
    'Sports'         =>  ['Sports',           /\b(sport)/i],
    'Talk'           =>  ['Talk',             /\b(talk)/i],
    'Travel'         =>  ['Travel',           /\b(travel)/i],
    'War'            =>  ['War',              /\b(war)/i],
    'Western'        =>  ['Western',          /\b(west)/i],
    #  These last two are some other classes that we might want to have
    #  show up in the category legend (they don't need regular
    #  expressions)
    'Unknown'        =>  ['Unknown'],
    'movie'          =>  ['Movie'  ]
      }

    

  # ScheduledResource protocol...

  # OBSOLETE
  # 
  # Assigns a block id -- nothing to do with the database
  @@serial = 0
  # 
  #        What *in* mean depends on INC.  If INC(remental) is false,
  #        client is building interval from scratch.  If "hi", it is
  #        an addition to an existing interval on the high side...

end







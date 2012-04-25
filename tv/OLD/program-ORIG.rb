class Program < ActiveRecord::Base
  set_table_name     "program"    # Would default to "programs"
  belongs_to        :channel,
                    :class_name   => "Channel",
                    :foreign_key  => "chanid"

  attr_accessor :css_classes, :block_label, :detail_list, :rsid


  ################################################################
  # ScheduledResource protocol...

  # Assigns a block id -- nothing to do with the database
  @@serial = 0

  # Builds a hash -- each key is a Resource object; value is a list of blocks
  #        Key represents one channel; the blocks (programs) are those 
  #        <em>in</em> the *t1*..*t2* time interval, ordered by starttime.
  #
  #        What <em>in</em> mean depends on *inc*.
  #        If inc(remental) is false, client is building interval
  #        from scratch.  If "hi", it is an addition to an existing
  #        interval on the high side.
  def Program.get_all_blocks( chanids, t1, t2, inc )
    condlo = "(endtime) > "
    condlo = "(starttime) >=" if inc == "hi"
    
    condhi = "(starttime) <"
    condhi = "(endtime) <=" if inc == "lo"
    
    qry  = "SELECT * FROM program "
    qry << "WHERE program.chanid IN (" + chanids.join(",") + ") "
    qry <<    "AND UNIX_TIMESTAMP#{condlo} #{t1.to_i} "
    qry <<    "AND UNIX_TIMESTAMP#{condhi} #{t2.to_i} "
    qry << "ORDER BY chanid MOD 1000, starttime;"

    blocks = {}
    Program.programs_by_channel( t1, Program.find_by_sql(qry) ) do |pgms|
      blocks[ pgms[0].chanid ] = pgms
    end # chanid (eg, 2002)        --> Sched.srid(rsrc)  (eg, "Channel_2002")
        # Sched.id(rsrc)
    return blocks
  end

  ################################################################

  # Groups adjacent programs with same chanid.
  def Program.programs_by_channel( t, programs )
    serial =  ( t.to_i.modulo 10000000 )        # Overflow: approx 10 days 
    while (len = programs.length) > 0 do
      chanid0 = programs[0].chanid

      i = 0;
      while i < len && chanid0 == programs[i].chanid do
        programs[i].rsid = "ch" + ( serial += 1 ).to_s
        i += 1 
      end
        
      pgms = programs.slice!(0, i)
      
      for pgm in pgms do
        pgm.set_visual_info()
      end
      
      yield pgms
    end
    
  end

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
    'Misc'           =>  ['Misc',         /\b(special|variety|info|collect)/i],
    'News'           =>  ['News',             /\b(news|current)/i],
    'Reality'        =>  ['Reality',          /\b(reality)/i],
    'Romance'        =>  ['Romance',          /\b(romance)/i],
    'SciFi_Fantasy'  =>  ['SciFi / Fantasy',  /\b(fantasy|sci\\w*\\W*fi)/i],
    'Science_Nature' =>  ['Science / Nature',/\b(science|nature|environment)/i],
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

end

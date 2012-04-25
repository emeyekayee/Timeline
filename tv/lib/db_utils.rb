# Utilities for testing/manipulating DBs for mythconverg & tvg app.
# Mike Cannon (Wed Mar 21 ''12) 

def l(o) o.length end

# RATHER, Use database.yml['production']
ProdDbConnection = { adapter: 'mysql2', host: 'mjc3', database: 'mythconverg',
                     username: "mythtv", password: 'Xdl5bjo6' } 
                   
class ProdChannel < ActiveRecord::Base
  self.table_name  = "channel"
  self.primary_key = "chanid"
  has_many           :prod_programs
  establish_connection ProdDbConnection
end

class ProdProgram < ActiveRecord::Base
  self.table_name = "program"
  belongs_to        :channel,
                    :class_name   => "Channel",
                    :foreign_key  => "chanid" 
  establish_connection ProdDbConnection
end

CHANNEL_ATTRS = [ "chanid", "channum", "callsign", "name", "visible" ]

PROGRAM_ATTRS = %w(chanid title subtitle description starttime endtime 
                   category category_type stars airdate previouslyshown)

# COPY all visible channels -- Producton --> 
def copy_visible_channels_production_to_development()
  pchs = ProdChannel.all :conditions => "visible"; l pchs
  pchs.each{|pch|
    # pch = pchs.shift
    ch = Channel.new
    CHANNEL_ATTRS.each{|f| ch.send( :write_attribute, f, pch.send(f) )}
    ch.save
  }; nil
end
# Just need to do this once...
# copy_visible_channels_production_to_development()


def copy_todays_programs_for_a_few_channels()
  t1 = Time.now.change(hour: 0); t1s = t1.to_s.sub( / -\d\d\d\d/, '' )
  t2 = t1 + 1.day              ; t2s = t2.to_s.sub( / -\d\d\d\d/, '' )

  chanids = %w{737 738 189 190 201 204 756 757
               }.map{|s| ("1" + s).dump}.join(", ")
  cond = "chanid IN (#{chanids})" 
  cond = "(#{cond}) AND (starttime < '#{t2s}') AND (endtime > '#{t1s}')"

  ppgms = ProdProgram.all( conditions: cond ); l ppgms
  ppgms.each{|ppgm|
    # ppgm = ppgms.shift
    pgm = Program.new  # {}
    PROGRAM_ATTRS.each{|f| pgm.send( :write_attribute, f, ppgm.send(f) )}
    pgm.save
  }; nil
end
# copy_todays_programs_for_a_few_channels()



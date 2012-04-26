require 'spec_helper'

describe ScheduleController do
  render_views

  describe "Build config" do
    it "Resource and resource USE classes are valid" do

      yml = YAML.load_file("config/schedule.yml")

      yml['ResourceKinds'].each { |key, val|
        assert( eval(key).class == Class ) # Resource class
        assert( eval(val).class == Class ) # Resource USE class
      }
    end
  end


  describe "GET 'test'" do
    it "passes configuration sanity test" do
      get 'test'

      config = SchedResource.config
      
      kinds1 = config[:blockClassForResourceKind].keys
      kinds2 = config[:rsrcs_by_kind].keys

      # assert (kinds1 - kinds2) == []
      (kinds1 - kinds2).should == []
      (kinds2 - kinds1).should == []
      
      kinds = kinds1
      # assert( kinds.length > 0 )
      kinds.length.should be > 0

      kinds.each{ |kind| 
        # assert( config[:rsrcs_by_kind][kind].length > 0,
        #         "There should be at least one resource of kind #{kind}" )
        config[:rsrcs_by_kind][kind].length.should be > 0

        klass = config[:blockClassForResourceKind][kind].class

        # assert( klass == Class, "No class found for use blocks of #{kind}." )
        klass.should == Class
      }

      response.should be_success
    end
  end

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'show'" do
    it "returns http success" do
      get 'show'

      # puts "\n\n"
      # #  puts "==> Rspec for ScheduleController: "
      # puts "\nRipl running in Rspec --  self is #{self}"
      # require 'ripl'
      # Ripl.start :binding => binding
      # puts "Leaving Ripl...\n\n"
      
      response.should be_success
    end
  end

end

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


  describe "Validate resource specifications" do
    it "Has only valid resource specs." do

      rsrcs = SchedResource.configFromYaml1[:all_resources]            
      rsrcs.all?.should == true

    end
  end


  describe "Validate configuration consistency." do
    it "Shows a consistent set of resource classes.." do

      config = SchedResource.configFromYaml({})
      
      kinds1 = config[:blockClassForResourceKind].keys
      kinds2 = config[:rsrcs_by_kind].keys

      (kinds1 - kinds2).should == []
      (kinds2 - kinds1).should == []
      
      kinds = kinds1
      kinds1.length.should be > 0

      kinds.each{ |kind| 
        config[:rsrcs_by_kind][kind].length.should be > 0

        klass = config[:blockClassForResourceKind][kind].class

        klass.should == Class
      }

    end
  end


  describe "GET 'test'" do
    it "passes configuration sanity test" do
      get 'test'

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

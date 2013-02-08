require 'spec_helper'

root = File.expand_path("../../support/processes", __FILE__)

describe Ruote::ProcessLibrary do
  before(:each) do
    @library = Ruote::ProcessLibrary.new(root)

    @dash.register_participant "debug" do |wi|
      text = wi.params['text'] || wi.params['message']
      wi.fields["trace"] << "debug"
 
      if text
        text.gsub!(/\$\{f:([^\}]+)\}/) { wi.fields[$1] }
        STDERR.puts "{#{wi.wfid}}: #{text}"
      else
        STDERR.puts "{#{wi.wfid}}: WORKITEM : #{wi.fields.inspect}"
      end
    end

    @dash.register_participant "*" do |wi|
      wi.fields['trace'] << wi.params['ref']
    end
  end

  describe :single_process do
    it "should raise an error on non-existing files" do
      expect {
        @library.fetch("ce-ci-nest-pas-une-file")
      }.to raise_error(Ruote::ProcessLibrary::ProcessNotFound)
    end

    it "should fetch a json process" do
      pdef = @library.fetch("json.json")
      pdef.should be_kind_of String
    end
    
    it "should fetch an xml process" do
      pdef = @library.fetch("xml.xml")
      pdef.should be_kind_of String
    end
    
    it "should auto-apply an extension" do
      pdef = @library.fetch("xml")
      pdef.should be_kind_of String
    end
    
    it "should return a radial process" do
      pdef = @library.fetch("json")
      pdef.should be_kind_of String

      Ruote::Reader.to_radial(Ruote::Reader.read(pdef)).should eq pdef
    end
    
    it "should be executable" do
      pdef = @library.fetch("json")
      wfid = @dash.launch(pdef, { trace: [] } )
      res  = @dash.wait_for(wfid)
      
      res.should trace(%w[alpha bravo charlie])
    end
  end

  describe :sub_process do
    it "should not read a subprocess when defined" do
      pdef = @library.fetch("defined")
      wfid = @dash.launch(pdef, { trace: [] } )
      res  = @dash.wait_for(wfid)
      
      res.should trace(%w[abc_alpha abc_bravo abc_charlie])
    end
    
    it "should read a subprocess when not defined" do
      pdef = @library.fetch("subs")
      wfid = @dash.launch(pdef, { trace: [] } )
      res  = @dash.wait_for(wfid)
      
      res.should trace(%w[root_alpha root_beta alpha bravo charlie])      
    end

    it "should read subprocess recursively" do
      pdef = @library.fetch("recursive")
      wfid = @dash.launch(pdef, { trace: [] } )
      res  = @dash.wait_for(wfid)
      
      res.should trace(%w[recursive_alpha root_alpha alpha])      
    end
    
    it "should read from subdirectories" do
      pdef = @library.fetch("army/build")
      pdef.should be_kind_of String
    end
    
    it "should read from subdirectories recursively" do
      pdef = @library.fetch("country/attack")
      pdef.should be_kind_of String
      
      wfid = @dash.launch(pdef, { trace: [] } )
      res  = @dash.wait_for(wfid)
      
      res.should trace(
        %w[recruit_troops train_troops build_phalanx_formation send_formation]
      )
    end
  end

  describe :inclusion do
    it "includes other processes" do
      pdef = @library.fetch("inclusive/test")
      pdef.should == "define inclusive/test
  foo
  bar
  cursor
    recruit_troops
    train_troops
    rewind unless: \"${f:enough_troops}\"
    build_phalanx_formation
    send_formation direction: forward\n"
    end
  end
end

require 'spec_helper'

# mute UI
module Guard::UI
  class << self
    def info(message, options = {})
    end
    
    def error(message)
    end
    
    def debug(message)
    end
  end
end

describe Guard do
  
  describe "get_guard_class" do
    
    it "should return Guard::RSpec" do
      Guard.get_guard_class('rspec').should == Guard::RSpec
    end
    
  end
  
  describe "locate_guard" do
    
    it "should return guard-rspec gem path" do
      guard_path = Guard.locate_guard('rspec')
      guard_path.should match(/^.*\/guard-rspec-.*$/)
      guard_path.should == guard_path.chomp
    end
    
  end
  
  describe "init" do
    subject { ::Guard.init }
    
    it "Should retrieve itself for chaining" do
      subject.should be_kind_of(Module)
    end
    
    it "Should init guards array" do
      ::Guard.guards.should be_kind_of(Array)
    end
    
    it "Should init options" do
      opts = {:my_opts => true}
      ::Guard.init(opts).options.should be_include(:my_opts)
    end
    
    it "Should init listeners" do
      ::Guard.listener.should be_kind_of(Guard::Listener)
    end
  end

  describe "start" do

    before(:each) do
      @guard = mock(::Guard::Guard)
      @guard.stub!(:reload_at_start?).and_return(false)
      @guard.stub!(:run_all_at_start?).and_return(false)

      @listener = mock(::Guard::Polling)
      @listener.stub!(:on_change)
      @listener.stub!(:start).and_return(true)

      ::Guard::Listener.stub!(:init).and_return(@listener)
      ::Guard::Dsl.stub!(:evaluate_guardfile)
      ::Guard::Interactor.stub!(:init_signal_traps)
      subject.stub!(:guards).and_return([@guard])
      subject.stub!(:supervised_task).with(anything(), :start).and_return(true)
    end

    it 'should evaluate Guardfile' do
      ::Guard::Dsl.should_receive(:evaluate_guardfile)
      subject.start
    end

    it 'should init signal traps' do
      ::Guard::Interactor.should_receive(:init_signal_traps)
      subject.start
    end

    it 'should define listener on_change' do
      @listener.should_receive(:on_change)
      subject.start
    end

    it 'should start guards' do
      subject.should_receive(:supervised_task).with(@guard, :start).and_return(true)
      subject.start
    end

    it 'should call method definined to run at start' do
      @guard.class.stub(:instance_methods).with(false).and_return([:test, :test_at_start?])

      @guard.should_receive(:run_all_at_start?).and_return(true)
      @guard.should_receive(:run_all).and_return(true)

      @guard.should_receive(:test_at_start?).and_return(true)
      @guard.should_receive(:test).and_return(true)

      subject.start
    end

    it 'should not call method definined to not run at start' do
      @guard.class.stub(:instance_methods).with(false).and_return([:test, :test_at_start?])

      @guard.should_receive(:run_all_at_start?).and_return(false)
      @guard.should_not_receive(:run_all)

      @guard.should_receive(:test_at_start?).and_return(false)
      @guard.should_not_receive(:test)

      subject.start
    end
    
  end
  
  describe "supervised_task" do
    subject { ::Guard.init }
    
    before :each do
      @g = mock(Guard::Guard)
      @g.stub!(:respond_to).and_return { false }
      @g.stub!(:regular).and_return { true }
      @g.stub!(:spy).and_return { raise "I break your system" }
      @g.stub!(:pirate).and_raise Exception.new("I blow your system up")
      @g.stub!(:regular_arg).with("given_path").and_return { "given_path" }
      @g.stub!(:enable_method).and_return { true }
      @g.stub!(:enable_method?).and_return { true }
      @g.stub!(:respond_to).with(:enable_method?).and_return { true }
      @g.stub!(:disable_method).and_return { true }
      @g.stub!(:disable_method?).and_return { false }
      @g.stub!(:respond_to).with(:disable_method?).and_return { true }
      subject.guards.push @g
    end
    
    it "should let it go when nothing special occurs" do
      subject.guards.should be_include(@g)
      subject.supervised_task(@g, :regular).should be_true
      subject.guards.should be_include(@g)
    end
    
    it "should let it work with some tools" do
      subject.guards.should be_include(@g)
      subject.supervised_task(@g, :regular).should be_true
      subject.guards.should be_include(@g)
    end
    
    it "should fire the guard on spy act discovery" do
      subject.guards.should be_include(@g)
      ::Guard.supervised_task(@g, :spy).should be_kind_of(Exception)
      subject.guards.should_not be_include(@g)
      ::Guard.supervised_task(@g, :spy).message.should == 'I break your system'
    end
    
    it "should fire the guard on pirate act discovery" do
      subject.guards.should be_include(@g)
      ::Guard.supervised_task(@g, :regular_arg, "given_path").should be_kind_of(String)
      subject.guards.should be_include(@g)
      ::Guard.supervised_task(@g, :regular_arg, "given_path").should == "given_path"
    end

    it 'should let it go when method is enable by guard options' do
      subject.guards.should be_include(@g)
      subject.supervised_task(@g, :enable_method).should be_true
      subject.guards.should be_include(@g)
    end

    it 'should not let it go when method is disable by guard options' do
      subject.guards.should be_include(@g)
      subject.supervised_task(@g, :disable_method).should be_false
      subject.guards.should be_include(@g)
    end

  end
  
end

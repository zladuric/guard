require 'spec_helper'
require 'guard/guard'

describe Guard::Guard do
  subject { Guard::Guard }

  it "should be initialized with watchers" do
    watcher = mock(Guard::Watcher)
    guard = subject.new([watcher])
    guard.watchers.should == [watcher]
  end

  it "should be initialized with options" do
    watcher = mock(Guard::Watcher)
    guard = subject.new([], {:test => true})
    guard.options[:test].should be_true
    guard.options[:fake].should be_nil
  end

  context "#reload?" do

    it "should return true by default" do
      subject.new.reload?.should be_true
    end

    it "should return true with option `:reload => {:disable => false}'" do
      guard = subject.new([], :reload => {:disable => false})
      guard.reload?.should be_true
    end

    it "should return true with option `:reload => {}'" do
      guard = subject.new([], :reload => {})
      guard.reload?.should be_true
    end

    it "should return true with option `:reload => true'" do
      guard = subject.new([], :reload => true)
      guard.reload?.should be_true
    end

    it "should return false with option `:reload => {:disable => true}'" do
      guard = subject.new([], :reload => {:disable => true})
      guard.reload?.should be_false
    end

    it "should return false with option `:reload => false'" do
      guard = subject.new([], :reload => false)
      guard.reload?.should be_false
    end

  end

  context "#reload_at_start?" do

    it "should return false by default" do
      subject.new.reload_at_start?.should be_false
    end

    it "should return false with option `:reload => {:at_start => false}'" do
      guard = subject.new([], :reload => {:at_start => false})
      guard.reload_at_start?.should be_false
    end

    it "should return false with option `:reload => {}'" do
      guard = subject.new([], :reload => {})
      guard.reload_at_start?.should be_false
    end

    it "should return false with option `:reload => true'" do
      guard = subject.new([], :reload => true)
      guard.reload_at_start?.should be_false
    end

    it "should return false with option `:reload => false'" do
      guard = subject.new([], :reload => false)
      guard.reload_at_start?.should be_false
    end

    it "should return true with option `:reload => {:at_start => true}'" do
      guard = subject.new([], :reload => {:at_start => true})
      guard.reload_at_start?.should be_true
    end

  end

  context "#run_all?" do

    it "should return true by default" do
      subject.new.run_all?.should be_true
    end

    it "should return true with option `:reload => {:disable => false}'" do
      guard = subject.new([], :run_all => {:disable => false})
      guard.run_all?.should be_true
    end

    it "should return true with option `:reload => {}'" do
      guard = subject.new([], :run_all => {})
      guard.run_all?.should be_true
    end

    it "should return true with option `:reload => true'" do
      guard = subject.new([], :run_all => true)
      guard.run_all?.should be_true
    end

    it "should return false with option `:reload => {:disable => true}'" do
      guard = subject.new([], :run_all => {:disable => true})
      guard.run_all?.should be_false
    end

    it "should return false with option `:reload => false'" do
      guard = subject.new([], :run_all => false)
      guard.run_all?.should be_false
    end

  end

  context "#run_all_at_start?" do

    it "should return false by default" do
      subject.new.run_all_at_start?.should be_false
    end

    it "should return false with option `:reload => {:at_start => false}'" do
      guard = subject.new([], :run_all => {:at_start => false})
      guard.run_all_at_start?.should be_false
    end

    it "should return false with option `:reload => {}'" do
      guard = subject.new([], :run_all => {})
      guard.run_all_at_start?.should be_false
    end

    it "should return false with option `:reload => true'" do
      guard = subject.new([], :run_all => true)
      guard.run_all_at_start?.should be_false
    end

    it "should return false with option `:reload => false'" do
      guard = subject.new([], :run_all => false)
      guard.run_all_at_start?.should be_false
    end

    it "should return true with option `:reload => {:at_start => true}'" do
      guard = subject.new([], :run_all => {:at_start => true})
      guard.run_all_at_start?.should be_true
    end

  end
  
end

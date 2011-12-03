require 'spec_helper'

describe Redis::Document do

  describe ".redis" do
    subject { Redis::Document.redis }
    it { should be_a Redis }
  end

  describe ".redis=" do
    it "should set Redis::Document.redis" do
      thing = stub
      Redis::Document.redis = thing
      Redis::Document.redis.should == thing
    end
  end


  context "when included into a class" do

    class Post
      include ActiveModel::AttributeMethods
      include Redis::Document
    end

    subject{ Post.new }

    describe ".redis" do
      subject { Post.redis }
      it { should be_a Redis }
    end

    describe ".redis=" do
      it "should set Redis::Document.redis" do
        thing = stub
        Post.redis = thing
        Post.redis.should == thing
      end
    end

    describe ".redis" do
      subject { Redis::Document.redis }
      it { should be_a Redis }
    end


    it "should "

  end

end

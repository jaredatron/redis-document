require 'spec_helper'

describe Redis::Document do

  before do
    Redis::Document.instance_variable_set(:@redis, nil)
    Post.instance_variable_set(:@redis, nil)
  end

  describe ".redis" do
    subject { Redis::Document.redis }
    it { should be_a Redis }
  end

  describe ".redis=" do
    it "should set Redis::Document.redis" do
      redis = stub
      Redis::Document.redis = redis
      Redis::Document.redis.should == redis
    end
  end


  context "when included into a class" do

    subject{ Post.new }
    alias_method :post, :subject

    describe ".redis" do
      subject { Post.redis }
      it { should be_a Redis::Namespace }
    end

    describe ".redis=" do
      it "should set Redis::Document.redis" do
        redis = stub
        Post.redis = redis
        Post.redis.should be_a Redis::Namespace
        Post.redis.instance_variable_get(:@redis).should == redis
      end
    end

    describe ".keys" do
      it "should return an array of the documents keys" do
        Post.keys.should == [:title, :body]
      end
    end

    context "and subclassed" do
      subject{ AwesomePost.new }
      describe ".keys" do
        it "should return an array of the documents keys including its ancestors" do
          AwesomePost.keys.should == [:title, :body, :animated_gif]
        end
      end
    end

    describe "key" do
      class Shoe
        include Redis::Document
      end
      subject{ Shoe.new }
      it "should add attr_accessor methods that read and write to redis" do
        Shoe.key :color
        subject.should respond_to :color
        subject.should respond_to :color=
        Shoe.keys.should == [:color]
      end
    end

    describe "#inspect" do
      subject { Post.new.inspect }
      it { should be_a String }
    end

    describe "#new_record?" do
      it "should return true if our key exists in redis" do
        post = Post.new
        post.new_record?.should be_true
        post.title = 'My Second Post'
        post.new_record?.should be_false
      end
    end

    it "should store all of its data in a single redis hash" do
      post.id.should_not be_nil
      post.new_record?
    end

    it "should log to Redis::Document.logger" do
      post = Post.new
      log_lines.should be_empty

      post.new_record?
      log_lines.length.should == 1
      log_lines.first.should include "Post(#{post.id}) exists?"

      empty_log!
      post.title = "my first post"
      log_lines.length.should == 1
      log_lines.first.should include "Post(#{post.id}) write :title"

      empty_log!
      Post.find(post.id)
      log_lines.length.should == 2
      log_lines.last.should include "Post(#{post.id}) find"
    end

  end

end

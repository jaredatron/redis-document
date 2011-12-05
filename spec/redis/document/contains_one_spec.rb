require 'spec_helper'

describe Redis::Document do

  context "containing another" do

    describe Redis::Document do

      it "should store and refind associations" do
        post = Post.new
        video = Post::Video.new(:url => 'http://www.example.com')
        video.save

        post.video.should be_nil
        post.video_id.should be_nil

        post.video = video
        post.video.should == video
        post.video_id.should == video.id

        post.save

        post = Post.find(post.id)
        post.video.should == video
        post.video_id.should == video.id
      end

      it "should save unsaved associationed document instances" do
        post  = Post.new
        video = Post::Video.new(:url => 'http://www.example.com')
        post.video = video
        post.save
        post.video_id.should_not be_nil
        video.new_record?.should be_false
        video.id.should_not be_nil
        post.video_id.should == video.id
      end

      it "should persist the associated document within it's self" do
        # rather then having an ID it should be in a redis namespace

      end

    end
  end

end

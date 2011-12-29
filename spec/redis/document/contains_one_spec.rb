require 'spec_helper'

describe Redis::Document do

  before{
    class ::Frog
      include Redis::Document
    end
  }

  let(:frog){ Frog.new }

  context "with a contains_one to Heart" do
    before{
      class ::Heart
        include Redis::Document
      end
      class ::Frog
        contains_one :heart
      end
    }

    pending "should respond to frog_heart" do
      frog.should respond_to :heart
      frog.id.should be_nil
      frog.save
      frog.id.should_not be_nil
      frog.heart = Heart.new
      debugger;1
      frog.save
      Frog.find(frog.id).heart.should be_a Heart
    end

  end

end

require 'spec_helper'

describe Redis::Document do

  # context "containing another" do

  #   describe Redis::Document do

  #     class Car
  #       include Redis::Document
  #       contains_one :engine
  #       class Engine
  #         include Redis::Document
  #         key :size
  #       end
  #     end

  #     subject{ Car.new }
  #     alias_method :car, :subject

  #     it "should store that objects data in a namespace" do
  #       car.engine.should be_a Car::Engine
  #       car.engine.size = 5
  #       car.save
  #       Car.find(car.id).engine.size.should == 5
  #     end

  #   end
  # end

end

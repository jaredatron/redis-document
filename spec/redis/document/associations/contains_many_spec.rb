require 'spec_helper'

describe Redis::Document do

  context "containing many" do

    describe Redis::Document do

      class Car
        include Redis::Document
        contains_many :wheels
        class Wheel
          include Redis::Document
          key :radius
        end
      end

      subject{ Car.new }
      alias_method :car, :subject

      it "should store that objects data in a namespace" do
        car.wheels.should == []
        car.wheels.length.should == 0
        car.wheels.new.should be_a Car::Wheel
        car.wheels.length.should == 1
        car.save
        Car.find(car.id).wheels.length.should == 1
      end

    end
  end

end

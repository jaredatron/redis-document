shared_examples_for "it has keys" do

  describe "key" do
    it "should add attr_accessor methods that read and write to redis" do
      subject.class.key :color
      subject.should respond_to :color
      subject.should respond_to :color=
      subject.keys.should == [:color]
      subject.class.keys.should == [:color]
    end
  end

  CLASSES = [Symbol, String, Integer, Float, Time, Array, Hash]
  VALUES  = [:boosh, 'Love', 42, 10.5, Time.now, [:an,'array'], {:a=>'hash'}]
  it "should persist keys" do
    CLASSES.each{|klass| subject.class.key :"a_#{klass}"}

    CLASSES.each{|klass|
      subject.should respond_to :"a_#{klass}"
      subject.should respond_to :"a_#{klass}="
    }

    CLASSES.zip(VALUES).each{|klass, value|
      subject.send(:"a_#{klass}=", value)
      subject.send(:"a_#{klass}").should be_a klass
      subject.send(:"a_#{klass}").should == value
    }
  end

end

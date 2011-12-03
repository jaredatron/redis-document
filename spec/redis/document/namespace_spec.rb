require 'spec_helper'

describe Redis::Document::Namespace do

  context "when included into a class" do

    context ".document" do
      subject{ Class.new{ include Redis::Document::Namespace } }
      it "should that :is => thing and define the document method" do
        subject.document :is => :ballz

        instance = subject.new
        instance.should_receive(:ballz)
        instance.document
      end
    end

  end

end

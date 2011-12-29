require 'spec_helper'

describe Redis::DataSet do

  let(:post){ Redis::DataSet["Post:0"] }
  let(:author){ post.data_set("Author") }


  def self.it_should_persist
    it "should persist" do

      subject.persisted.should == {}
      subject.changed.should == {}
      subject.deleted.should == []
      subject.keys.should == []
      subject.persisted?.should be_false
      subject.dirty?.should be_false

      subject[:name] = 'Steve'
      subject.persisted.should == {}
      subject.changed.should == {"name" => 'Steve'}
      subject.deleted.should == []
      subject.keys.should == ["name"]
      subject.persisted?.should be_false
      subject.dirty?.should be_true

      subject["age"] = 24
      subject.persisted.should == {}
      subject.changed.should == {"name" => 'Steve', "age" => 24}
      subject.deleted.should == []
      subject.keys.to_set.should == Set["name", "age"]
      subject.persisted?.should be_false
      subject.dirty?.should be_true

      subject.save.should be_true
      subject.persisted.should == {"name" => 'Steve', "age" => 24}
      subject.changed.should == {}
      subject.deleted.should == []
      subject.keys.to_set.should == Set["name", "age"]
      subject.persisted?.should be_true
      subject.dirty?.should be_false

      subject.delete(:age)
      subject.persisted.should == {"name" => 'Steve'}
      subject.changed.should == {}
      subject.deleted.should == ["age"]
      subject.keys.to_set.should == Set["name"]
      subject.persisted?.should be_true
      subject.dirty?.should be_true

      subject.save.should be_true
      subject.persisted.should == {"name" => 'Steve'}
      subject.changed.should == {}
      subject.deleted.should == []
      subject.keys.should == ["name"]
      subject.persisted?.should be_true
      subject.dirty?.should be_false

      subject.reload
      subject.persisted.should == {"name" => 'Steve'}
      subject.changed.should == {}
      subject.deleted.should == []
      subject.keys.should == ["name"]
      subject.persisted?.should be_true
      subject.dirty?.should be_false

    end
  end

  subject{ post }
  it_should_persist

  context "when nested" do
    subject{ author }
    context "and it's parent is saved" do
      subject{
        author.parent[:title] = "some post"
        author.parent.save.should be_true
        author
      }
      it_should_persist
    end
    it "should not save when it's parent is not persisted" do
      subject[:name] = 'smelly pants'
      subject.save.should be_false
      subject.parent[:anything] = 'at all'
      subject.parent.save.should be_true
      subject.save.should be_true
    end
  end

  def keys
    Redis.current.keys.to_set
  end

  it "should write keys to redis" do
    keys.should == Set[]

    post.set :title, "sweet as"
    keys.should == Set[
      'Post:0:title'
    ]

    post.set :body, "zomg this is awesome"
    keys.should == Set[
      'Post:0:title',
      'Post:0:body',
    ]

    author.set :name, 'Jared'
    keys.should == Set[
      'Post:0:title',
      'Post:0:body',
      'Post:0:Author:name',
    ]

    address = author.data_set('Address')
    address.set :street, '1633 Avon st.'
    keys.should == Set[
      'Post:0:title',
      'Post:0:body',
      'Post:0:Author:name',
      'Post:0:Author:Address:street',
    ]

    comment = post.data_set('Comment:0')
    comment.set :content, "this post sucks."
    keys.should == Set[
      'Post:0:title',
      'Post:0:body',
      'Post:0:Author:name',
      'Post:0:Author:Address:street',
      'Post:0:Comment:0:content',
    ]

  end

  describe "#save" do
    it "should return false if there are no keys to save" do
      post.save.should be_false
      post[:a] = :b
      post.save.should be_true
    end
  end

  describe "#persisted" do
    pending "…"
  end

  describe "#changed" do
    pending "…"
  end

  describe "#deleted" do
    pending "…"
  end

  describe "#persisted?" do
    pending "…"
  end

  describe "#changed?" do
    pending "…"
  end

  describe "#dirty?" do
    pending "…"
  end


end

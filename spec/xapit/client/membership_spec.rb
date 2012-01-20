require "spec_helper"

describe Xapit::Client::Membership do
  before(:each) do
    @member_class = XapitMember
  end

  it "does not define search class method when xapit isn't called" do
    member_class = Class.new
    member_class.send(:include, Xapit::Client::Membership)
    member_class.should_not respond_to(:search)
  end

  it "has a xapit method which makes an index builder" do
    @member_class.xapit { text :foo }
    @member_class.xapit_index_builder.attributes.keys.should eq([:foo])
  end

  it "returns collection with query on search" do
    @member_class.xapit { text :foo }
    @member_class.search("hello").clauses.should eq([{:in_classes => [@member_class.name]}, {:search => "hello"}])
  end

  it "returns collection with no search query" do
    @member_class.xapit { text :foo }
    @member_class.search.clauses.should eq([{:in_classes => [@member_class.name]}])
    @member_class.search("").clauses.should eq([{:in_classes => [@member_class.name]}])
  end

  it "supports xapit_search instead of just search" do
    @member_class.xapit { text :foo }
    @member_class.xapit_search.clauses.should eq([{:in_classes => [@member_class.name]}])
  end

  it "includes facets" do
    @member_class.xapit { facet :foo }
    @member_class.search.clauses.should eq([{:in_classes => [@member_class.name]}, {:include_facets => [:foo]}])
  end

  it "has a model_adapter" do
    @member_class.xapit { } # load up the xapit methods
    @member_class.xapit_model_adapter.should be_kind_of(Xapit::Client::DefaultModelAdapter)
  end

  it "includes xapit_relevance" do
    load_xapit_database
    XapitMember.xapit { text :name }
    member = XapitMember.new(:name => "foo")
    XapitMember.xapit_index_builder.add_document(member)
    XapitMember.search("foo").first.xapit_relevance.should eq(100)
  end
end

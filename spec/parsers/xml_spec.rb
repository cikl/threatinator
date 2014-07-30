require 'spec_helper'
require 'threatinator/parsers/xml'
require 'threatinator/parsers/xml/pattern'

describe Threatinator::Parsers::XML, :parser do
  context "two instances with identically configured patterns" do
    it_should_behave_like "a parser when compared to an identically configured parser" do
      let(:pattern1) { Threatinator::Parsers::XML::Pattern.new('/foo/bar') }
      let(:pattern2) { Threatinator::Parsers::XML::Pattern.new('/foo/bar') }
      let(:parser1) { Threatinator::Parsers::XML.new(pattern: pattern1) }
      let(:parser2) { Threatinator::Parsers::XML.new(pattern: pattern2) }
    end
  end

  context "two instances with differently configured patterns" do
    it_should_behave_like "a parser when compared to a differently configured parser" do
      let(:pattern1) { Threatinator::Parsers::XML::Pattern.new('/foo/bar') }
      let(:pattern2) { Threatinator::Parsers::XML::Pattern.new('//foo/bar') }
      let(:parser1) { Threatinator::Parsers::XML.new(pattern: pattern1) }
      let(:parser2) { Threatinator::Parsers::XML.new(pattern: pattern2) }
    end
  end

  shared_examples_for "an XML::Record" do
    it { is_expected.to be_a(Threatinator::Parsers::XML::Record) }
    its(:node) { is_expected.to be_a(Threatinator::Parsers::XML::Node) }
  end


  shared_examples_for "a parser matching nothing" do
    it "should yield 0 records" do
      expect(records.count).to eq(0)
    end
  end # 

  shared_context "parsing xml" do
    let(:io) { StringIO.new(xml) }
    let(:parser) { described_class.new(pattern: pattern) }
    let!(:records) { 
      ret = []
      parser.run(io) { |r| ret << r }
      ret
    }
  end

  context "parsing records from test_self_closing.xml" do
    let(:xml) { File.read(parser_data('test_self_closing.xml')) } 
    include_context "parsing xml"

    shared_examples_for "a parser matching each 'z' element" do
      it "should yield 4 records" do
        expect(records.count).to eq(4)
      end

      describe "record 0" do
        let(:record) { records[0] }
        let(:node) { record.node }
        subject { record }
        it_should_behave_like "an XML::Record"
        describe "the data from the node" do
          subject { node } 
          its(:name) { is_expected.to eq(:z) }
          its(:attrs) { is_expected.to eq({foo: "bar1"}) }
          its(:text) { is_expected.to eq("") }
        end
      end
      describe "record 1" do
        let(:record) { records[1] }
        let(:node) { record.node }
        subject { record }
        it_should_behave_like "an XML::Record"
        describe "the data from the node" do
          subject { node } 
          its(:name) { is_expected.to eq(:z) }
          its(:attrs) { is_expected.to eq({foo: "bar2"}) }
          its(:text) { is_expected.to eq("") }
        end
      end
      describe "record 2" do
        let(:record) { records[2] }
        let(:node) { record.node }
        subject { record }
        it_should_behave_like "an XML::Record"
        describe "the data from the node" do
          subject { node } 
          its(:name) { is_expected.to eq(:z) }
          its(:attrs) { is_expected.to eq({foo: "bar3"}) }
          its(:text) { is_expected.to eq("")}
        end
      end
      describe "record 3" do
        let(:record) { records[3] }
        let(:node) { record.node }
        subject { record }
        it_should_behave_like "an XML::Record"
        describe "the data from the node" do
          subject { node } 
          its(:name) { is_expected.to eq(:z) }
          its(:attrs) { is_expected.to eq({foo: "bar4"}) }
          its(:text) { is_expected.to eq("")}
        end
      end
    end # 

    context "with the pattern '/doc/x/y/z'" do
      let(:pattern) { Threatinator::Parsers::XML::Pattern.new("/doc/x/y/z") }
      it_should_behave_like "a parser matching each 'z' element"
    end

    context "with the pattern '//x/y/z'" do
      let(:pattern) { Threatinator::Parsers::XML::Pattern.new("//x/y/z") }
      it_should_behave_like "a parser matching each 'z' element"
    end

    context "with the pattern '//z'" do
      let(:pattern) { Threatinator::Parsers::XML::Pattern.new("//z") }
      it_should_behave_like "a parser matching each 'z' element"
    end


    context "with the pattern '/y/z/x'" do
      let(:pattern) { Threatinator::Parsers::XML::Pattern.new("/y/z/x") }
      it_should_behave_like "a parser matching nothing"
    end
  end

  context "parsing records from test.xml" do
    let(:xml) { File.read(parser_data('test.xml')) } 
    include_context "parsing xml"

    shared_examples_for "a parser matching each 'b' element" do
      it "should yield 2 records" do
        expect(records.count).to eq(2)
      end

      describe "record 0" do
        let(:record) { records[0] }
        let(:node) { record.node }
        subject { record }
        it_should_behave_like "an XML::Record"
        describe "the data from the node" do
          subject { node } 
          its(:name) { is_expected.to eq(:b) }
          its(:attrs) { is_expected.to eq({}) }
          its(:text) { is_expected.to eq("")}
          its(:children) { 
            is_expected.to match(
              {
                c: a_collection_containing_exactly(
                  build(:xml_node, name: 'c', text: 'deep1A'),
                  build(:xml_node, name: 'c', text: 'deep1B')
                )
              }
            )
          }
        end
      end
      describe "record 1" do
        let(:record) { records[1] }
        let(:node) { record.node }
        subject { record }
        it_should_behave_like "an XML::Record"
        describe "the data from the node" do
          subject { node } 
          its(:name) { is_expected.to eq(:b) }
          its(:attrs) { is_expected.to eq({}) }
          its(:text) { is_expected.to eq("")}
          its(:children) { 
            is_expected.to match(
              {
                c: a_collection_containing_exactly(
                  build(:xml_node, name: 'c', text: 'deep2A'),
                  build(:xml_node, name: 'c', text: 'deep2B')
                )
              }
            )
          }
        end
      end
    end # 

    shared_examples_for "a parser matching each 'c' element" do
      it "should yield 4 records" do
        expect(records.count).to eq(4)
      end

      describe "record 0" do
        let(:record) { records[0] }
        let(:node) { record.node }
        subject { record }
        it_should_behave_like "an XML::Record"
        describe "the data from the node" do
          subject { node } 
          its(:name) { is_expected.to eq(:c) }
          its(:attrs) { is_expected.to eq({}) }
          its(:text) { "deep1A" }
        end
      end
      describe "record 1" do
        let(:record) { records[1] }
        let(:node) { record.node }
        subject { record }
        it_should_behave_like "an XML::Record"
        describe "the data from the node" do
          subject { node } 
          its(:name) { is_expected.to eq(:c) }
          its(:attrs) { is_expected.to eq({}) }
          its(:text) { "deep1B" }
        end
      end
      describe "record 2" do
        let(:record) { records[2] }
        let(:node) { record.node }
        subject { record }
        it_should_behave_like "an XML::Record"
        describe "the data from the node" do
          subject { node } 
          its(:name) { is_expected.to eq(:c) }
          its(:attrs) { is_expected.to eq({}) }
          its(:text) { "deep2A" }
        end
      end
      describe "record 3" do
        let(:record) { records[3] }
        let(:node) { record.node }
        subject { record }
        it_should_behave_like "an XML::Record"
        describe "the data from the node" do
          subject { node } 
          its(:name) { is_expected.to eq(:c) }
          its(:attrs) { is_expected.to eq({}) }
          its(:text) { "deep2B" }
        end
      end
    end # 

    context "with the pattern '/doc/a/b/c'" do
      let(:pattern) { Threatinator::Parsers::XML::Pattern.new("/doc/a/b/c") }
      it_should_behave_like "a parser matching each 'c' element"
    end


    context "with the pattern '//a/b/c'" do
      let(:pattern) { Threatinator::Parsers::XML::Pattern.new("//a/b/c") }
      it_should_behave_like "a parser matching each 'c' element"
    end

    context "with the pattern '//b'" do
      let(:pattern) { Threatinator::Parsers::XML::Pattern.new("//b") }
      it_should_behave_like "a parser matching each 'b' element"
    end

    context "with the pattern '//c'" do
      let(:pattern) { Threatinator::Parsers::XML::Pattern.new("//a/b/c") }
      it_should_behave_like "a parser matching each 'c' element"
    end

    context "with the pattern '/c/b/a'" do
      let(:pattern) { Threatinator::Parsers::XML::Pattern.new("/c/b/a") }
      it_should_behave_like "a parser matching nothing"
    end
  end
end

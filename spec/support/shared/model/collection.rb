require 'spec_helper'

shared_examples_for "a model collection" do
  # expect generate_ten_valid_members, generate_invalid_members
  let(:collection) { described_class.new }

  describe "initialize" do
    context "when no parameters are provided" do
      specify "the collection is empty" do
        x = described_class.new
        expect(x).to be_empty
      end
    end

    context "when an array of members is provided" do
      it "calls #<< for each member, adding it to the collection" do
        members = generate_ten_valid_members()
        expect_any_instance_of(described_class).to receive(:<<).exactly(10).times.and_call_original
        x = described_class.new(members)
        expect(x.to_a).to match_array(members)
      end
    end
  end
  describe "#<<(member)" do
    it "adds the member to the collection" do
      member = generate_ten_valid_members()[0]
      expect(collection.include?(member)).to eq(false)
      collection << member
      expect(collection.include?(member)).to eq(true)
    end

    it "does not add the member if it is equal to any member of the collection" do
      member = generate_ten_valid_members()[0]
      expect(collection.count).to eq(0)
      collection << member
      expect(collection.count).to eq(1)
      collection << member
      expect(collection.count).to eq(1)
    end

    it "raises InvalidAttributeError if the added member is not valid for the collection" do
      expect {
        collection << generate_invalid_members()[0]
      }.to raise_error(Threatinator::Exceptions::InvalidAttributeError)
    end
  end
  
  describe "#valid_member?(member)" do
    it "returns true if the member is valid" do
      expect(collection.valid_member?(generate_ten_valid_members()[0])).to eq(true)
    end
    it "returns false if the member is not valid" do
      expect(collection.valid_member?(generate_invalid_members()[0])).to eq(false)
    end
  end

  describe "#include?(member)" do
    let(:member) { generate_ten_valid_members()[0] }
    it "returns true if the member is in the collection" do
      collection << member
      expect(collection).to include(member)
    end

    it "returns false if the member is not in the collection" do
      expect(collection).not_to include(member)
    end
  end

  describe "#empty?" do
    it "returns true when the collection is empty" do
      expect(collection).to be_empty
    end
    it "returns false when something has been added to the collection" do
      member = generate_ten_valid_members()[0]
      collection << member
      expect(collection).not_to be_empty
    end
  end

  describe "#count" do
    it "returns 0 when the collection is empty" do
      expect(collection.count).to eq(0)
    end

    it "returns the number of members in the collection" do
      members = generate_ten_valid_members()
      members.each do |member|
        collection << member
      end
      expect(collection.count).to eq(members.count)
    end
  end

  [:to_ary, :to_a].each do |method_name|
    describe "##{method_name}" do 
      it "returns an empty array instance when the collection is empty" do
        expect(collection.send(method_name)).to eq([])
      end

      it "returns an array containing members that have been added" do
        members = generate_ten_valid_members()
        members.each do |member|
          collection << member
        end
        expect(collection.send(method_name)).to match_array(members)
      end
    end
  end

  describe "#each" do
    it "returns an Enumerator if no block is provided" do
      expect(collection.each).to be_a(::Enumerator)
    end

    it "yields each member of the collection" do
      members = generate_ten_valid_members()
      members.each do |member|
        collection << member
      end

      actual = []
      collection.each do |member|
        actual << member
      end

      expect(actual).to match_array(members)
    end
  end

  describe "#==(other)" do
    before :each do
    end

    it "returns true when compared to itself" do
      collection = described_class.new(generate_ten_valid_members())
      expect(collection).to be == collection
    end

    it "returns true when compared to a collection with equal members" do
      collection = described_class.new(generate_ten_valid_members())
      collection2 = described_class.new(generate_ten_valid_members())
      expect(collection).to be == collection2
    end

    it "returns false if the number of members is different" do
      collection = described_class.new(generate_ten_valid_members()[0..5])
      collection2 = described_class.new(generate_ten_valid_members())
      expect(collection).not_to be == collection2
    end

    it "returns false if the members are different" do
      collection = described_class.new(generate_ten_valid_members()[0..4])
      collection2 = described_class.new(generate_ten_valid_members()[5..9])
      expect(collection).not_to be == collection2
    end

    it "returns false when compared to something other than a collection" do
      members = generate_ten_valid_members()
      collection = described_class.new(members)
      expect(collection).not_to be == members
    end
  end
end


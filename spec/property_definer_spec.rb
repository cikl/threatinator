require 'spec_helper'
require 'threatinator/property_definer'

describe Threatinator::PropertyDefiner do
  describe "defining a property" do
    let(:klass) {
      Class.new do
        include Threatinator::PropertyDefiner
        property :my_prop
      end
    }
    it "should add a setter for the property you define" do
      klass = Class.new do
        include Threatinator::PropertyDefiner
        property :some_prop
      end
      expect(klass.new).to respond_to(:some_prop=)
    end
    it "should add a getter for the property you define" do
      klass = Class.new do
        include Threatinator::PropertyDefiner
        property :another_prop
      end
      expect(klass.new).to respond_to(:another_prop)
    end
  end

  describe "getting and setting properties" do
    let(:klass) {
      Class.new do
        include Threatinator::PropertyDefiner
        property :my_prop
      end
    }
    it "should let me set the value of a property and retrieve it" do
      instance = klass.new
      instance.my_prop = 1234
      expect(instance.my_prop).to eq(1234)
    end
    it "the getter should respond with nil by default" do
      instance = klass.new
      expect(instance.my_prop).to be_nil
    end
  end
  describe ":type (type validation)" do
    context "when :type is set to a class" do
      let(:klass) {
        Class.new do
          include Threatinator::PropertyDefiner
          property :my_prop, type: Integer
        end
      }
      let(:instance) { klass.new }

      it "should not raise an error if the property is set to a instance of the specified class" do
        expect{instance.my_prop = 1234}.not_to raise_error
      end

      it "should raise an InvalidAttributeError if the property being set is not of its defined type" do
        expect{instance.my_prop = "asdf"}.to raise_error do |e|
          expect(e).to be_a(Threatinator::Exceptions::InvalidAttributeError)
          expect(e.attribute).to eq(:my_prop)
        end
      end
    end
  end

  describe ":validate" do
    it "should raise an ArgumentError if :validate is not a proc" do
      expect {
        Class.new do
          include Threatinator::PropertyDefiner
          property :my_prop, validate: 1234
        end
      }.to raise_error(ArgumentError)

    end

    it "should call the validate block whenever the associated attribute is set" do
      expect { |b|
        klass = Class.new do
          include Threatinator::PropertyDefiner
          property :my_prop, validate: lambda { |obj, val| b.to_proc.call(obj, val); true }
        end
        instance = klass.new
        instance.my_prop = "value1"
        instance.my_prop = "value2"
      }.to yield_successive_args(
        [kind_of(Threatinator::PropertyDefiner), "value1"], 
        [kind_of(Threatinator::PropertyDefiner), "value2"])
    end

    it "should raise an InvalidAttributeError if the validation block returns false" do
      klass = Class.new do
        include Threatinator::PropertyDefiner
        property :my_prop, validate: lambda { |obj, val| false }
      end
      instance = klass.new
      expect { |b|
        instance.my_prop = "value1"
      }.to raise_error do |e|
        expect(e).to be_a(Threatinator::Exceptions::InvalidAttributeError)
        expect(e.attribute).to eq(:my_prop)
      end
    end
    it "should not raise an error if the validation block returns true" do
      klass = Class.new do
        include Threatinator::PropertyDefiner
        property :my_prop, validate: lambda { |obj, val| true }
      end
      instance = klass.new
      expect { |b|
        instance.my_prop = "value1"
      }.not_to raise_error
    end
  end

  describe ":default" do
    context "when :default is set to a value" do
      it "should return the object when accessed via a getter" do
        expected_object = "my_val"
        klass = Class.new do
          include Threatinator::PropertyDefiner
          property :my_prop, default: expected_object
        end
        instance = klass.new
        expect(instance.my_prop).to be(expected_object)
      end
    end
    context "when :default is set to a proc" do
      it "should not call the proc if a value is provided" do
        expect { |b| 
          klass = Class.new do
            include Threatinator::PropertyDefiner
            property :my_prop, default: b.to_proc
          end
          instance = klass.new
          instance.my_prop = 1234
        }.not_to yield_control
      end
      it "should only call the proc once, and only when it is accessed" do
        expect { |b| 
          klass = Class.new do
            include Threatinator::PropertyDefiner
            property :my_prop, default: lambda { b.to_proc.call(); }
          end
          instance = klass.new
          val1 = instance.my_prop
          val2 = instance.my_prop
          val3 = instance.my_prop
        }.to yield_control.exactly(1).times
      end
    end
  end
end

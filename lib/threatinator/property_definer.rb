
module Threatinator
  # A helper that lets us easily define properties within an object and
  # validate them.
  module PropertyDefiner
    def self.included(base)
      base.extend(Threatinator::PropertyDefiner::ClassMethods)
    end

    def _properties
      @_properties ||= Hash.new
    end

    def _prop(name)
      self.class._properties[name]
    end

    def _get(name)
      if _properties.has_key?(name)
        return _properties[name]
      end
      prop = _prop(name)
      return nil if prop.nil?
      val = prop.default_value
      _set(name, val)
      val
    end

    def _set(name, val)
      prop = _prop(name)
      return if prop.nil?
      prop.validate!(self, val)
      _properties[name] = val
    end

    def _parse_properties(opts = {})
      opts.each { |k, v| _set(k, v) }
    end

    class Property
      attr_reader :name, :opts
      def initialize(name, opts = {})
        @name = name.to_sym
        @type = opts.delete(:type) || Object
        if @validator = opts.delete(:validate) 
          unless @validator.kind_of?(Proc)
            raise ArgumentError.new(":validate must be a proc")
          end
        end
        @default_value = opts.delete(:default)
        @opts = opts
      end

      def default_value
        case @default_value
        when Proc
          return @default_value.call()
        when nil
          return nil
        else 
          return @default_value
        end
      end

      def valid?(obj, val)
        return false unless val.kind_of?(@type)
        unless @validator.nil?
          return false unless @validator.call(obj, val)
        end
        true
      end

      def validate!(obj, val)
        unless valid?(obj, val)
          raise Threatinator::Exceptions::InvalidAttributeError.new(self.name, val)
        end
      end
    end

    module ClassMethods
      def _properties
        @@properties ||= {}
      end

      def _define_property(prop)
        name = prop.name
        _properties[name] = prop
        define_method("#{prop.name}=".to_sym) do |newval|
          _set(name, newval)
        end
        define_method(name) do 
          _get(name)
        end
      end

      def property(name, opts = {})
        _define_property(Property.new(name, opts))
      end
    end
  end
end

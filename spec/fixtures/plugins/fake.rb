require 'threatinator/output'
module FakeOutputPlugins
  class Plugin1 < Threatinator::Output
    class Config < superclass::Config
      attribute :foo
    end
  end
  class Plugin2 < Threatinator::Output
    class Config < superclass::Config
      attribute :bar
    end
  end
  class Plugin3 < Threatinator::Output
    class Config < superclass::Config
      attribute :woof
    end
  end
end


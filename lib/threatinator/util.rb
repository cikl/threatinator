
module Threatinator
  module Util
    def underscore2cc(str)
      str.to_s.split('_').map {|e| e.capitalize }.join
    end
    module_function :underscore2cc

    def cc2underscore(str)
      str.to_s.split('_').map {|e| e.capitalize }.join
    end
    module_function :underscore2cc
  end
end


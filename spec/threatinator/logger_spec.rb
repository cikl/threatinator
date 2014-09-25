require 'spec_helper'
require 'threatinator/logger'
require 'threatinator/config/logger'

describe Threatinator::Logger do
  before :each do
    @orig_level = Threatinator::Logger.level
  end

  after :each do
    Threatinator::Logger.level = @orig_level
  end

  describe ".configure_logger(config)" do
    let(:config) { Threatinator::Config::Logger.new }
    it "sets the logging level to that specified by config.level" do
      Threatinator::Logger.level = Threatinator::Logger::Levels::FATAL
      config.level = "DEBUG"
      Threatinator::Logger.configure_logger(config)
      expect(Threatinator::Logger.level).to eq(Threatinator::Logger::Levels::DEBUG)
    end

    it "warns when an unknown logging level is provided" do
      config.level = "FOO"
      expect(Threatinator::Logger.default_logger).to receive(:warn).with(/Ignoring unknown logging level:/)
      Threatinator::Logger.configure_logger(config)
    end
  end
end

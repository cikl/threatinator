require 'stringio'
module IOHelpers
  def temp_stdout
    $stdout = StringIO.new
    yield $stdout.string
  ensure
    $stdout = STDOUT
  end
end


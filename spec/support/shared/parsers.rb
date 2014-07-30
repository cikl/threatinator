shared_examples_for "a parser when compared to an identically configured parser" do
  it "parser1 should eql? parser2" do
    expect(parser1).to eql(parser2)
  end
  it "parser2 should eql? parser1" do
    expect(parser2).to eql(parser1)
  end
  it "parser1 should == parser2" do
    expect(parser1).to be == parser2
  end
  it "parser2 should == parser1" do
    expect(parser2).to be == parser1
  end
  it "parser1 should not be parser2" do
    expect(parser1).not_to be parser2
  end
  it "parser2 should not be parser1" do
    expect(parser2).not_to be parser1
  end
end

shared_examples_for "a parser when compared to a differently configured parser" do
  it "parser1 should not eql? parser2" do
    expect(parser1).not_to eql(parser2)
  end
  it "parser2 should not eql? parser1" do
    expect(parser2).not_to eql(parser1)
  end
  it "parser1 should not == parser2" do
    expect(parser1).not_to be == parser2
  end
  it "parser2 should not == parser1" do
    expect(parser2).not_to be == parser1
  end
  it "parser1 should not be parser2" do
    expect(parser1).not_to be parser2
  end
  it "parser2 should not be parser1" do
    expect(parser2).not_to be parser1
  end
end

module ParserHelpers
  def parser_data(filename)
    (PARSER_DATA_ROOT + filename).to_s
  end
end

shared_context "a parser", :parser do
  include ParserHelpers
end

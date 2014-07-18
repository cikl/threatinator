
shared_examples_for "an IO-like object" do
  it { is_expected.to respond_to(:close) }
  it { is_expected.to respond_to(:read) }
  it { is_expected.to respond_to(:gets) }
  it { is_expected.to respond_to(:pos) }
end

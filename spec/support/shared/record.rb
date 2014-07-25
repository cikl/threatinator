shared_examples_for 'a record when compared to an identically configured record' do
  let(:record1) { described_class.new(data, opts) }
  let(:record2) { described_class.new(data2, opts2) }
  specify "record1 should == record2" do
    expect(record1).to be == record2
  end
  specify "record2 should == record1" do
    expect(record2).to be == record1
  end
  specify "record1 should eql? record2" do
    expect(record1).to eql record2
  end
  specify "record2 should eql? record1" do
    expect(record2).to eql record1
  end
end

shared_examples_for 'a record when compared to a differently configured record' do
  let(:record1) { described_class.new(data, opts) }
  let(:record2) { described_class.new(data2, opts2) }
  specify "record1 should not == record2" do
    expect(record1).not_to be == record2
  end
  specify "record2 should not == record1" do
    expect(record2).not_to be == record1
  end
  specify "record1 should not eql? record2" do
    expect(record1).not_to eql record2
  end
  specify "record2 should not eql? record1" do
    expect(record2).not_to eql record1
  end
end

shared_examples_for 'a record' do
  let(:record) { described_class.new(data, opts) }
  context "when compared to itself" do
    it_should_behave_like 'a record when compared to an identically configured record' do
      let(:data2) { Marshal.load(Marshal.dump(data)) }
      let(:opts2) { Marshal.load(Marshal.dump(opts)) }
    end
  end
  describe "initialization options" do
    describe "data" do
      it "should be accessible via #data" do
        expect(record.data).to eq(data)
      end
    end
    describe ":line_number" do
      context "when not set" do
        it "should default to nil" do
          expect(record.line_number).to be_nil
        end
      end
      context "when set" do
        before :each do
          opts[:line_number] = 1234
        end
        it "should be readable via #line_number" do
          expect(record.line_number).to eq(1234)
        end

        it_should_behave_like 'a record when compared to an identically configured record' do
          let(:data2) { Marshal.load(Marshal.dump(data)) }
          let(:opts2) { Marshal.load(Marshal.dump(opts)) }
        end
      end
    end
    describe ":pos_start" do
      context "when not set" do
        it "should default to nil" do
          expect(record.pos_start).to be_nil
        end
      end
      context "when set" do
        before :each do
          opts[:pos_start] = 999
        end
        it "should be readable via #pos_start" do
          expect(record.pos_start).to eq(999)
        end

        it_should_behave_like 'a record when compared to an identically configured record' do
          let(:data2) { Marshal.load(Marshal.dump(data)) }
          let(:opts2) { Marshal.load(Marshal.dump(opts)) }
        end
      end
    end
    describe ":pos_end" do
      context "when not set" do
        it "should default to nil" do
          expect(record.pos_end).to be_nil
        end
      end
      context "when set" do
        before :each do
          opts[:pos_end] = 555
        end

        it "should be readable via #pos_end" do
          expect(record.pos_end).to eq(555)
        end

        it_should_behave_like 'a record when compared to an identically configured record' do
          let(:data2) { Marshal.load(Marshal.dump(data)) }
          let(:opts2) { Marshal.load(Marshal.dump(opts)) }
        end
      end
    end
  end
end

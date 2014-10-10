require "spec_helper"

describe AEMO::NEM12::File do
  let(:nem_file) { AEMO::NEM12::File.new(file) }

  context "file is invalid" do
    let(:file) { fixture("NEM12/nem12_valid.csv") }

    describe "#initialize" do
      it "creates and instance" do
        expect(nem_file).to be_a(AEMO::NEM12::File)
      end
    end

    describe "#header" do
      it "creates a valid header record" do
        expect(nem_file.header.valid?).to be_truthy
      end
    end

    describe "#nmis" do
      before do
        nem_file.parse_nmis
      end

      it "gets all unique NMIs present in the file" do
        expect(nem_file.nmis).to_not be_empty
      end
    end
  end
end

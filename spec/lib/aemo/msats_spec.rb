require 'spec_helper'

describe AEMO::MSATS do
  describe 'instance methods' do
    it 'creates a new instance' do
      expect(AEMO::MSATS.new.class).to eq(AEMO::MSATS)
    end
  end

  describe 'class methods' do
    describe 'nmi details' do
      before(:each) do
        AEMO::MSATS.authorize("ER","ER","ER")
      end

      it 'should get data for a valid nmi' do
        nmi_detail_query = AEMO::MSATS.nmi_detail('4001234567')
        expect(nmi_detail_query.class).to eq(Hash)
      end
      it 'should get a 404 for a nonexistent nmi' do
        nmi_detail_query = AEMO::MSATS.nmi_detail('4001234566')
        # TODO workout what the different errors are here...
      end
      it 'should raise an error for a bad nmi' do
        expect {AEMO::MSATS.nmi_detail('BOBISAFISH')}.to raise_error(ArgumentError)
      end
    end
  end
end

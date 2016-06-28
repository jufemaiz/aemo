require 'spec_helper'

describe AEMO::NMI::UnitOfMeasurement do
  describe 'Class Methods' do
    describe '#valid?' do
      it 'identifies a valid uom' do
        expect(AEMO::NMI::UnitOfMeasurement.valid?('KWH')).to eq(true)
      end

      it 'identifies an invalid uom' do
        expect(AEMO::NMI::UnitOfMeasurement.valid?('BOB')).to eq(false)
      end
    end

    describe '.multiplier' do
      it 'raises ArgumentError' do
        expect { AEMO::NMI::UnitOfMeasurement.multiplier('BOB')}.to raise_error(ArgumentError)
      end

      it 'returns the multiplier' do
        expect(AEMO::NMI::UnitOfMeasurement.multiplier('M')).to eq(1e6)
      end
    end

    describe '.covert' do
      it 'converts 1234567890Wh to 1234.567890GWh' do
        expect(AEMO::NMI::UnitOfMeasurement.convert(1234567890, '', 'G')).to eq(1.234567890)
      end
    end
  end

  describe 'Instance Methods' do
    describe '#initialize' do
      it 'invalid' do
        expect { AEMO::NMI::UnitOfMeasurement.new('bob') }.to raise_error(ArgumentError)
      end

      it 'valid' do
        expect { AEMO::NMI::UnitOfMeasurement.new('kwh') }.not_to raise_error(ArgumentError)
      end
    end

    describe '#convert_to' do
      it 'valid conversion from AEMO::NMI::UnitOfMeasurement to AEMO::NMI::UnitOfMeasurement' do
        old_uom = AEMO::NMI::UnitOfMeasurement.new('kWh')
        new_uom = AEMO::NMI::UnitOfMeasurement.new('Wh')
        expect(old_uom.convert_to(1.2345,new_uom)).to eq(1234.5)
      end

      it 'valid conversion from AEMO::NMI::UnitOfMeasurement to String' do
        old_uom = AEMO::NMI::UnitOfMeasurement.new('kWh')
        expect(old_uom.convert_to(1.2345,'')).to eq(1234.5)
      end
    end

    describe '#title' do
      it 'with prefix' do
        uom = AEMO::NMI::UnitOfMeasurement.new('kWh')
        expect(uom.title).to eq('Kilowatt Hour')
      end

      it 'without prefix' do
        uom = AEMO::NMI::UnitOfMeasurement.new('Wh')
        expect(uom.title).to eq('Watt Hour')
      end
    end

    describe '#abbreviation' do
      it do
        uom = AEMO::NMI::UnitOfMeasurement.new('kWh')
        expect(uom.abbreviation).to eq('kWh')
      end
    end
  end
end

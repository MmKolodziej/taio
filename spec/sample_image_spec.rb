require 'rspec'
require_relative '../sample_image'

describe SampleImage do
  let(:subject) { described_class.new('spec/fixtures/image_1.csv', '1') }
  let(:symbols_list) { [:a, :b, :c, :d, :e] }

  context 'methods' do
    let(:vector) { [2, 0, 0.5, 0.1, 0.7] }
    let(:normalized_vector) { [0.4, 0.5, 0.5, 0.1, 0.7] }

    it "normalizes factors" do
      expect(subject.normalize(vector)).to eq(normalized_vector)
    end

    it 'creates symbol vector' do
      expect(subject.create_symbols_vector(symbols_list, normalized_vector)).to eq([:c, :c, :c, :a, :d])
    end
  end

  context 'initializing from CSV' do
    it 'works perfectly' do
      expect(subject.map_factors(symbols_list)).to eq([:b, :b, :b, :c, :e])
    end
  end
end

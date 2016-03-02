require 'spec_helper'

RSpec.describe PageRepresenter do
  subject(:presenter) { PageRepresenter }

  before do
    @p1 = Page.new(name: 'pageid1', config: {key1: 'val1'})
    @p2 = Page.new(name: 'pageid2', config: {key2: 'val2'})
  end

  describe '.prepare' do
    let(:expected_output) do
      {
        page: {
          id: 'pageid1',
          config: {
            key1: 'val1'
          }
        }
      }.to_json
    end

    it 'presents a single resource' do
      expect(presenter.prepare(@p1).to_json).to eq expected_output
    end
  end

  describe '.for_collection' do
    describe '.prepare' do
      let(:expected_output) do
        {
          page: [
            {
              id: 'pageid1',
              config: {
                key1: 'val1'
              }
            },
            {
              id: 'pageid2',
              config: {
                key2: 'val2'
              }
            } 
          ]     
        }.to_json
      end

      it 'presents collection of resources' do      
        expect(presenter.for_collection.prepare([@p1, @p2]).to_json).to eq expected_output
      end
    end
  end

end

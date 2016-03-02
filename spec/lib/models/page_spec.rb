require 'spec_helper'

RSpec.describe Page do

  describe 'callbacks' do

    describe 'sanitize_name' do
      let(:name) { '12 hello-world %' }

      it 'sanitizes name by downcasing and removing all non-alphanumeric characters' do
        expect(Page.create(name: name, config: {key1: 'val1'}).name).to eq '12helloworld'
      end
    end

  end

  describe 'validations' do

    describe 'name' do
      it 'should be present' do
        p = Page.new(config: {key1: 'val1'})
        expect(p).to_not be_valid
        expect(p.errors[:name]).to include("can't be blank")

        p.name = 'foo'
        expect(p).to be_valid
      end
    end

    describe 'config' do
      it 'should be present' do
        p = Page.new(name: 'foo')
        expect(p).to_not be_valid
        expect(p.errors[:config]).to include("can't be blank")

        p.config = {key1: 'val1'}
        expect(p).to be_valid
      end
    end

  end
end

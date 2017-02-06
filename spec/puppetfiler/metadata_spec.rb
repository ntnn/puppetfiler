require 'spec_helper'
require 'puppetfiler/metadata'

describe Puppetfiler::Metadata do
    let!(:md) {
        Puppetfiler::Metadata.new('./data/simple_metadata.json')
    }

    describe 'instance variables' do
        it 'sets the path' do
            expect(md.path).to eq('./data/simple_metadata.json')
        end

        it 'parses dependencies' do
            expect(md.dependencies)
                .to eql(
                    [
                        Puppetfiler::Metadata::Dependency.new('puppetlabs/stdlib', '>= 4.13.0 < 5.0.0')
                    ]
                )
        end
    end
end

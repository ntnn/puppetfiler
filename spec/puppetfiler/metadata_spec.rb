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
                    {
                        'puppetlabs/stdlib' => Puppetfiler::Metadata::Dependency.new('puppetlabs/stdlib', '>= 4.13.0 < 5.0.0').version,
                    }
                )
        end

        it 'fails on no dependencies' do
            expect(Puppetfiler::Metadata.new('./data/metadata_nodeps.json'))
                .to eql(Puppetfiler::Metadata.new('./data/metadata_emptydeps.json'))
        end
    end

    describe '#fixture' do
        it 'returns a correct fixture hash' do
            expect(md.fixture)
                .to eql(
                    {
                        'fixtures' => {
                            'forge_modules' => {
                                'stdlib' => {
                                    'repo' => 'puppetlabs/stdlib',
                                    'ref'  => '4.15.0',
                                },
                            },
                        },
                    }
                )
        end
    end
end

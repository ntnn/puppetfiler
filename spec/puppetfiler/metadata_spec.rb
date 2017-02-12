require 'spec_helper'
require 'puppetfiler/metadata'

describe Puppetfiler::Metadata do
    let!(:md) {
        Puppetfiler::Metadata.new(File.new('./data/simple_metadata.json'))
    }

    describe 'initialization / instance variables' do
        it 'parses dependencies' do
            expect(md.dependencies)
                .to eql(
                    {
                        'puppetlabs/stdlib' => Puppetfiler::Mod.new(
                            :name => 'puppetlabs/stdlib',
                            :range => SemanticPuppet::VersionRange.parse('>= 4.13.0 < 5.0.0'),
                        )
                    }
                )
        end

        {
            'empty' => './data/metadata_emptydeps.json',
            'no'    => './data/metadata_nodeps.json',
        }.each do |mess, file|
            it "prints a message to stderr on #{mess} dependencies" do
                expect { Puppetfiler::Metadata.new(File.new(file)) }
                    .to output(/No dependencies found/).to_stderr
            end
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

require 'spec_helper'

require 'puppetfiler/puppetfile'

describe Puppetfiler::Puppetfile do
    let!(:pf) { Puppetfiler::Puppetfile.new('./data/simple_puppetfile.rb') }

    describe 'instance variables' do
        it 'parses forge modules' do
            expect(pf.modules).to eql(
                {
                    'puppetlabs/stdlib' => Puppetfiler::Mod.new(:name => 'puppetlabs/stdlib', :version => '4.13.1'),
                }
            )
        end

        it 'parses vcs modules' do
            expect(pf.repos).to eql(@repos)
        end
    end

    describe '#updates' do
        it 'returns updates as a hash' do
            expect(pf.updates)
                .to eql(
                    {
                        'puppetlabs/stdlib' => {
                            :current => SemanticPuppet::Version.parse('4.13.1'),
                            :newest  => SemanticPuppet::Version.parse('4.15.0'),
                        }
                    }
                )
        end
    end
end

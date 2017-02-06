require 'spec_helper'

require 'puppetfiler/puppetfile'

describe Puppetfiler::Puppetfile do
    let!(:pf) { Puppetfiler::Puppetfile.new('./data/simple_puppetfile.rb') }

    describe 'instance variables' do
        it 'parses forge modules' do
            expect(pf.modules).to eql(@modules)
        end

        it 'parses vcs modules' do
            expect(pf.repos).to eql(@repos)
        end

        it 'sets maxlen_name' do
            expect(pf.maxlen_name).to eql('puppetlabs/stdlib'.length)
        end

        it 'sets maxlen_var' do
            expect(pf.maxlen_ver).to eql('current'.length)
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

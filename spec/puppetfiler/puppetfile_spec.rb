require 'spec_helper'

require 'puppetfiler/puppetfile'

describe Puppetfiler::Puppetfile do
    describe 'instance variables' do
        let(:pf) { Puppetfiler::Puppetfile.new('./data/simple_puppetfile.rb') }

        let(:modules) {
            {
                'puppetlabs/stdlib' => '4.13.1'
            }
        }
        let(:repos) {

            {
                'goscript' => {
                    :uri => 'https://github.com/ntnn/puppet-goscript',
                },
                'inifile'  => {
                    :uri => 'https://github.com/puppetlabs/puppetlabs-inifile',
                    :ref => '1.6.0',
                },
            }
        }

        it 'parses forge modules' do
            expect(pf.modules).to eql(modules)
        end

        it 'parses vcs modules' do
            expect(pf.repos).to eql(repos)
        end

        it 'sets maxlen_name' do
            expect(pf.maxlen_name).to eql('puppetlabs/stdlib'.length)
        end

        it 'sets maxlen_var' do
            expect(pf.maxlen_ver).to eql('current'.length)
        end

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

        it 'returns fixtures as a hash' do
            expect(pf.fixture)
                .to eql(
                    {
                        'forge_modules' => {
                            'stdlib' => {
                                'repo' => 'puppetlabs/stdlib',
                                'ref'  => '4.13.1',
                            },
                        },
                        'repositories'  => {
                            'goscript' => 'https://github.com/ntnn/puppet-goscript',
                            'inifile'  => {
                                'repo' => 'https://github.com/puppetlabs/puppetlabs-inifile',
                                'ref'  => '1.6.0',
                            },
                        },
                    }
                )
        end
    end
end

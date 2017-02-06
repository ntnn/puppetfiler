require 'spec_helper'

describe Puppetfiler do
    it 'has a version number' do
        expect(Puppetfiler::VERSION).not_to be nil
    end

    describe '#fixture' do
        it 'returns fixtures as a hash' do
            expect(Puppetfiler.fixture(@modules, @repos))
                .to eql(
                    {
                        'fixtures' => {
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
                        },
                    }
                )
        end

        it 'takes a hash with pattern matches and returns fixtures as a hash' do
            patterns = {
                'forge_modules' => {
                    /.*/ => {
                        'flags' => '--module_repository https://inhouse.forge.lan/',
                    },
                },
                'repositories' => {
                    'goscript' => 'https://alternative.uri/',
                    /^ini.+$/  => {
                        'flags' => '--verbose',
                    },
                },
            }

            expect(Puppetfiler.fixture(@modules, @repos, patterns))
                .to eql(
                    {
                        'fixtures' => {
                            'forge_modules' => {
                                'stdlib' => {
                                    'repo'  => 'puppetlabs/stdlib',
                                    'ref'   => '4.13.1',
                                    'flags' => '--module_repository https://inhouse.forge.lan/',
                                },
                            },
                            'repositories'  => {
                                'goscript' => 'https://alternative.uri/',
                                'inifile'  => {
                                    'repo'  => 'https://github.com/puppetlabs/puppetlabs-inifile',
                                    'ref'   => '1.6.0',
                                    'flags' => '--verbose',
                                },
                            },
                        },
                    }
                )
        end

        it 'turns a string uri into a hash upon merge' do
            patterns = {
                'repositories' => {
                    /.*/ => {
                        'flags' => '--verbose',
                    },
                },
            }

            repos = { 'goscript' => @repos['goscript'] }

            expect(Puppetfiler.fixture({}, repos, patterns))
                .to eql(
                    {
                        'fixtures' => {
                            'repositories' => {
                                'goscript' => {
                                    'repo' => 'https://github.com/ntnn/puppet-goscript',
                                    'flags' => '--verbose',
                                },
                            },
                        },
                    }
                )
        end
    end
end

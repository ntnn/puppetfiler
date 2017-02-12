require 'simplecov'
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

SimpleCov.command_name 'rspec'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'puppetfiler'
require 'rspec/expectations'

RSpec.configure do |config|
    config.before(:each) do
        @stdlib = double(
            'PuppetForge::Module',
            :current_release => double('PuppetForge::Release', :version => '4.15.0'),
            :releases => [
                double('PuppetForge::Release', :version => '4.15.0'),
                double('PuppetForge::Release', :version => '4.14.0'),
            ],
        )
        allow(PuppetForge::Module)
            .to receive(:find)
            .and_return(@stdlib)

        @extlib = double(
            'PuppetForge::Module',
            :current_release => double('PuppetForge::Release', :version => '1.1.0'),
            :releases => [
                double('PuppetForge::Release', :version => '1.1.0'),
                double('PuppetForge::Release', :version => '1.0.0'),
            ],
        )

        @modules = {
            'puppetlabs/stdlib' => '4.13.1',
            'puppet/extlib' => '1.1.0',
        }

        @repos = {
            'goscript' => {
                :uri => 'https://github.com/ntnn/puppet-goscript',
            },
            'inifile'  => {
                :uri => 'https://github.com/puppetlabs/puppetlabs-inifile',
                :ref => '1.6.0',
            },
        }
    end
end

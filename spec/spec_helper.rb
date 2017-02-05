$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'puppetfiler'
require 'rspec/expectations'

RSpec.configure do |config|
    config.before(:each) do
        @mod = double(
            'PuppetForge::Module',
            :current_release => double(
                'PuppetForge::Release',
                :version => '4.15.0'
            )
        )

        allow(PuppetForge::Module)
            .to receive(:find)
            .and_return(@mod)
    end
end

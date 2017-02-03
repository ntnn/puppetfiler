require 'spec_helper'
require 'semantic_puppet'

require 'puppetfiler/mod'

describe Puppetfiler::Mod do
    describe '::newest' do
        it 'returns the newest version' do
            mod = double(
                'PuppetForge::Module',
                :current_release => double(
                    'PuppetForge::Release',
                    :version => '4.15.0'
                )
            )

            expect(PuppetForge::Module)
                .to receive(:find)
                .and_return(mod)

            expect(Puppetfiler::Mod.newest('puppetlabs/stdlib'))
                .to eq(SemanticPuppet::Version.parse('4.15.0'))
        end
    end

end

require 'spec_helper'
require 'semantic_puppet'

require 'puppetfiler/mod'

describe Puppetfiler::Mod do
    describe '::newest' do
        it 'returns the newest version' do
            expect(Puppetfiler::Mod.newest('puppetlabs/stdlib'))
                .to eq(SemanticPuppet::Version.parse('4.15.0'))
        end
    end

end

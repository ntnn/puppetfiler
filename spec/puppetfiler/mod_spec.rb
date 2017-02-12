require 'spec_helper'
require 'semantic_puppet'

require 'puppetfiler/mod'

describe Puppetfiler::Mod do
    let!(:mod) { Puppetfiler::Mod.new(:name => 'puppetlabs/stdlib') }

    describe 'instance variables' do
        describe '#name' do
            it { expect(mod.name).to_not be nil }
            it { expect(mod.name).to eql('puppetlabs/stdlib') }

            context 'name with dashes' do
                it do
                    expect {
                        Puppetfiler::Mod.new(:name => 'puppetlabs/puppetlabs-stdlib')
                    }.to raise_error(/Names with dashes are disallowed:/)
                end
            end
        end

        describe '#slug' do
            it { expect(mod.name).to_not be nil }
            it { expect(mod.slug).to eql('puppetlabs-stdlib') }
        end

        describe '#range' do
            context 'range passed' do
                let!(:mod) do
                    Puppetfiler::Mod.new(
                        :name => 'puppetlabs/stdlib',
                        :range => '>= 4.13.0 < 5.0.0'
                    )
                end

                it { expect(mod.range).to_not be nil }
                it do
                    expect(mod.range)
                        .to eql(SemanticPuppet::VersionRange.parse('>= 4.13.0 < 5.0.0'))
                end
            end

            context 'no range passed' do
                it { expect(mod.range).to be nil }
            end
        end
    end

    describe '#version' do
        it { expect(mod.version).to_not be nil }
        it 'should expose a SemanticPuppet::Version equal to 4.15.0' do
            expect(mod.version).to eql(SemanticPuppet::Version.parse('4.15.0'))
        end

        context 'range excluding upper version' do
            let(:mod) do
                Puppetfiler::Mod.new(
                    :name  => 'puppetlabs/stdlib',
                    :range => '>= 4.14.0 < 4.15.0'
                )
            end

            it 'should return the highgest possible version' do
                expect(mod.version).to eql(SemanticPuppet::Version.parse('4.14.0'))
            end
        end
    end

    describe '#eql?' do
        {
            'simple equal' => {
                :params => { :name => 'puppetlabs/stdlib' },
                :eql    => true,
            },
            'same name, same version' => {
                :params => { :name => 'puppetlabs/stdlib', :version => '4.15.0' },
                :eql    => true,
            },
            'different name' => {
                :params => { :name => 'puppet/extlib' },
                :eql    => false,
            },
            'different name, same version' => {
                :params => { :name => 'puppet/extlib', :version => '4.15.0' },
                :eql    => false,
            },
            'same name, different version' => {
                :params => { :name => 'puppetlabs/stdlib', :version => '4.14.0' },
                :eql    => false,
            },
            'same name, version range' => {
                :params => { :name => 'puppetlabs/stdlib', :range => '>= 4.14.0 < 4.15.0' },
                :eql    => false,
            },
        }.each do |name, hash|
            context "#{name} #{hash[:params]}" do
                let(:other) { Puppetfiler::Mod.new(hash[:params]) }
                it { expect(other).to_not be nil }
                it { expect(mod.eql?(other)).to be hash[:eql] }
            end
        end
    end

    describe '#version' do
        context 'no version specified' do
            it { expect(mod.version).to_not be nil }
            it { expect(mod.version).to eql(mod.latest_valid) }
        end

        context 'version specified' do
            let(:mods) do
                Puppetfiler::Mod.new(
                    :name    => 'puppetlabs/stdlib',
                    :version => '4.15.0'
                )
            end

            it { expect(mod.version).to_not be nil }
            it { expect(mod.version).to eql(SemanticPuppet::Version.parse('4.15.0')) }
        end
    end

    describe '#latest' do
        it 'returns tha latest version' do
            expect(mod.version).to eql(SemanticPuppet::Version.parse('4.15.0'))
        end
    end

    describe '#valid_versions' do
        {
            'no range' => {
                :mod => { :name => 'puppetlabs/stdlib' },
                :eql => [],
            },
            'with range' => {
                :mod => { :name => 'puppetlabs/stdlib', :range => '>= 4.13.0 < 5.0.0' },
                :eql => [
                    SemanticPuppet::Version.parse('4.15.0'),
                    SemanticPuppet::Version.parse('4.14.0'),
                ],
            },
        }.each do |descr, hash|
            context descr do
                let(:mod) { Puppetfiler::Mod.new(hash[:mod]) }
                it { expect(mod.valid_versions).to_not be nil }
                it { expect(mod.valid_versions.count).to eql(hash[:eql].count) }
                it { expect(mod.valid_versions).to match_array(hash[:eql]) }
            end
        end
    end

    describe '#latest_valid' do
        {
            'no range' => {
                :mod => { :name => 'puppetlabs/stdlib' },
                :eql => SemanticPuppet::Version.parse('4.15.0'),
            },
            'with range' => {
                :mod => { :name => 'puppetlabs/stdlib', :range => '>= 4.13.0 < 5.0.0' },
                :eql => SemanticPuppet::Version.parse('4.15.0'),
            },
        }.each do |descr, hash|
            context descr do
                let(:mod) { Puppetfiler::Mod.new(hash[:mod]) }
                it { expect(mod.latest_valid).to_not be nil }
                it { expect(mod.latest_valid).to eql(hash[:eql]) }
            end
        end
    end

    describe '#version_valid' do
        {
            'no range set' => {
                :mod    => { :name => 'puppetlabs/stdlib' },
                :params => [],
                :eql    => false,
            },
            'correct range and version set' => {
                :mod    => {
                    :name    => 'puppetlabs/stdlib',
                    :range   => '>= 4.13.0 < 5.0.0',
                    :version => '4.15.0',
                },
                :params => [],
                :eql    => true,
            },
            'correct range set and version passed' => {
                :mod    => {
                    :name    => 'puppetlabs/stdlib',
                    :range   => '>= 4.13.0 < 5.0.0',
                },
                :params => ['4.15.0'],
                :eql    => true,
            },
            'range set and passed version out of bounds' => {
                :mod    => {
                    :name    => 'puppetlabs/stdlib',
                    :range   => '>= 4.13.0 < 5.0.0',
                },
                :params => ['5.15.0'],
                :eql    => false,
            },
        }.each do |descr, hash|
            context "should return #{hash[:eql]} on #{descr}" do
                let(:mod) { Puppetfiler::Mod.new(hash[:mod]) }
                it { expect(mod.version_valid(*hash[:params])).to_not be nil }
                it { expect(mod.version_valid(*hash[:params])).to eql(hash[:eql]) }
            end
        end
    end
end

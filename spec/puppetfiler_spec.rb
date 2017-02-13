require 'spec_helper'

describe Puppetfiler do
    describe '#detect' do
        context 'no Puppetfile or metadata.json' do
            let(:before) do
                allow(File)
                    .to_receive(:exists?)
                    .with('Puppetfile', 'metadata.json')
                    .and_return(false, false)
            end

            it 'should fail' do
                expect { Puppetfiler.detect }
                    .to raise_error(/No valid target found, aborting/)
            end
        end

        context 'truth table' do
            context 'set set' do
                it do
                    expect(Puppetfiler.detect(:arbitrary, 'values'))
                        .to_not be nil
                end
            end

            context 'set nil' do
                it do
                    expect { Puppetfiler.detect(:arbitrary, nil) }
                        .to raise_error(/Type and target are required/)
                end
            end

            context 'nil set' do
                it do
                    expect { Puppetfiler.detect(nil, 'values') }
                        .to raise_error(/Type and target are required/)
                end
            end
        end

        {
            'with Puppetfile' => {
                :return => [true, false],
                :eql    => [:puppetfile, 'Puppetfile'],
            },
            'with metadata.json' => {
                :return => [false, true],
                :eql    => [:metadata, 'metadata.json'],
            },
            'prefers Puppetfile' => {
                :return => [true, true],
                :eql    => [:puppetfile, 'Puppetfile'],
            },
        }.each do |descr, hash|
            context descr do
                before do
                    allow(File)
                        .to receive(:exists?)
                        .with('Puppetfile')
                        .and_return(hash[:return][0])

                    allow(File)
                        .to receive(:exists?)
                        .with('metadata.json')
                        .and_return(hash[:return][1])
                end

                it { expect(Puppetfiler.detect).to_not be nil }
                it { expect(Puppetfiler.detect).to eql(hash[:eql]) }
            end
        end
    end

    describe '#check' do
        context 'Puppetfile' do
            let!(:check) {
                Puppetfiler.check(:puppetfile, 'data/simple_puppetfile.rb')
            }

            it { expect(check).to_not be nil }
        end

        context 'metadata' do
            let!(:check) {
            }

            it do
                expect {
                    Puppetfiler.check(:metadata, 'data/simple_metadata.json')
                }.to raise_error(/Checking metadata.json.*not implement/)
            end
        end
    end

    describe '#fixture' do
        context 'Puppetfile' do
            let!(:fixture) {
                Puppetfiler.fixture(:puppetfile, 'data/simple_puppetfile.rb')
            }

            it { expect(fixture).to_not be nil }
        end

        context 'metadata' do
            let!(:fixture) {
                Puppetfiler.fixture(:metadata, 'data/simple_metadata.json')
            }

            it { expect(fixture).to_not be nil }
        end
    end

end

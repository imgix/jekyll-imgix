require 'spec_helper'

describe Jekyll::Imgix do

  it 'has a version number' do
    expect(Jekyll::Imgix::VERSION).not_to be nil
  end

  context 'single source' do
    let(:source) { "assets.imgix.net" }
    let(:template) do
      Class.new do
        include Jekyll::Imgix
      end.new
    end

    context 'development mode' do
      let(:url) { "https://google.com/cats.gif" }

      before do
        expect(Jekyll).to receive(:env).and_return("development")
      end

      it 'passes values through' do
        expect(template.imgix_url(url)).to eq url
      end
    end

    context 'production mode' do
      let(:path) { "/cats.gif" }
      let(:config) do
        {
          'imgix' => {
            'source' => source
          }
        }
      end
      let(:registers) do
        {
          site: double("Object", config: config)
        }
      end
      let(:context) {double("Object", registers: registers) }

      before do
        expect(Jekyll).to receive(:env).and_return("production")
        template.instance_variable_set(:@context, context)
      end

      it 'passes values through' do
        expect(template.imgix_url(path)).to eq "https://assets.imgix.net/cats.gif?ixlib=jekyll-#{Jekyll::Imgix::VERSION}"
      end

      it 'URL encodes param keys' do
        expect(template.imgix_url('demo.png', {'hello world' => 'interesting'})).to eq "https://assets.imgix.net/demo.png?ixlib=jekyll-#{Jekyll::Imgix::VERSION}&hello%20world=interesting"
      end

      it 'URL encodes param values' do
        expect(template.imgix_url('demo.png', {hello_world: '/foo"> <script>alert("hacked")</script><'})).to eq "https://assets.imgix.net/demo.png?ixlib=jekyll-#{Jekyll::Imgix::VERSION}&hello_world=%2Ffoo%22%3E%20%3Cscript%3Ealert%28%22hacked%22%29%3C%2Fscript%3E%3C"
      end

      it 'Base64 encodes Base64 param variants' do
        expect(template.imgix_url('~text', {txt64: 'I cannøt belîév∑ it wors! 😱'})).to eq "https://assets.imgix.net/~text?ixlib=jekyll-#{Jekyll::Imgix::VERSION}&txt64=SSBjYW5uw7h0IGJlbMOuw6l24oiRIGl0IHdvcu-jv3MhIPCfmLE"
      end

      it 'adds parameters' do
        expect(template.imgix_url(path, { w: 400, h: 300 })).to eq "https://assets.imgix.net/cats.gif?ixlib=jekyll-#{Jekyll::Imgix::VERSION}&w=400&h=300"
      end

      context 'secure_url_token specified' do
        let(:config) do
          {
            'imgix' => {
              'source' => source,
              'secure_url_token' => 'FACEBEEF',
              'include_library_param' => false
            }
          }
        end

        it 'signs the URL' do
          expect(template.imgix_url(path, { w: 400, h: 300 })).to eq "https://assets.imgix.net/cats.gif?w=400&h=300&s=e7e25321c9e007f36a8a4610662f32aa"
        end
      end

    end
  end

  context 'multiple sources' do
    context 'with default_source' do
      let(:sources) { { "assets.imgix.net" => nil, "assets2.imgix.net" => nil } }
      let(:default_source) { "assets.imgix.net" }
      let(:template) do
        Class.new do
          include Jekyll::Imgix
        end.new
      end

      context 'development mode' do
        let(:url) { "https://google.com/cats.gif" }

        before do
          expect(Jekyll).to receive(:env).and_return("development")
        end

        describe 'passes values through' do
          it 'with no source specified' do
            expect(template.imgix_url(url)).to eq url
          end

          it 'with explicit source specified' do
            expect(template.imgix_url(url, 'assets2.imgix.net')).to eq url
          end
        end
      end

      context 'production mode' do
        let(:path) { "/cats.gif" }
        let(:config) do
          {
            'imgix' => {
              'sources' => sources,
              'default_source' => default_source,
            }
          }
        end
        let(:registers) do
          {
            site: double("Object", config: config)
          }
        end
        let(:context) {double("Object", registers: registers) }

        before do
          expect(Jekyll).to receive(:env).and_return("production")
          template.instance_variable_set(:@context, context)
        end

        describe 'passes values through' do
          it 'with no source specified' do
            expect(template.imgix_url(path)).to eq "https://assets.imgix.net/cats.gif?ixlib=jekyll-#{Jekyll::Imgix::VERSION}"
          end

          it 'with explicit source specified' do
            expect(template.imgix_url(path, 'assets2.imgix.net')).to eq "https://assets2.imgix.net/cats.gif?ixlib=jekyll-#{Jekyll::Imgix::VERSION}"
          end

          it 'with unknown source specified' do
            expect {
              template.imgix_url(path, 'foo.bar')
            }.to raise_error(RuntimeError)
          end
        end

        describe 'adds parameters' do
          it 'with no source specified' do
            expect(template.imgix_url(path, { w: 400, h: 300 })).to eq "https://assets.imgix.net/cats.gif?ixlib=jekyll-#{Jekyll::Imgix::VERSION}&w=400&h=300"
          end

          it 'with explicit source specified' do
            expect(template.imgix_url(path, 'assets2.imgix.net', { w: 400, h: 300 })).to eq "https://assets2.imgix.net/cats.gif?ixlib=jekyll-#{Jekyll::Imgix::VERSION}&w=400&h=300"
          end

          it 'with unknown source specified' do
            expect {
              template.imgix_url(path, 'foo.bar', { w: 400, h: 300 })
            }.to raise_error(RuntimeError)
          end
        end

        context 'secure_url_token specified' do
          let(:config) do
            {
              'imgix' => {
                'include_library_param' => false,
                'default_source' => 'assets.imgix.net',
                'sources' => {
                  'assets.imgix.net' => 'FACEBEEF',
                  'assets2.imgix.net' => 'foobarbaz',
                }
              }
            }
          end

          describe 'signs the URL' do
            it 'with no source specified' do
              expect(template.imgix_url(path, { w: 400, h: 300 })).to eq "https://assets.imgix.net/cats.gif?w=400&h=300&s=e7e25321c9e007f36a8a4610662f32aa"
            end

            it 'with explicit source specified' do
              expect(template.imgix_url(path, 'assets2.imgix.net', { w: 400, h: 300 })).to eq "https://assets2.imgix.net/cats.gif?w=400&h=300&s=a47059971f1a8fb0c8bee75331feee26"
            end

            it 'with unknown source specified' do
              expect {
                template.imgix_url(path, 'foo.bar', { w: 400, h: 300 })
              }.to raise_error(RuntimeError)
            end
          end
        end
      end
    end

    context 'without default_source' do
      let(:sources) { { "assets.imgix.net" => nil, "assets2.imgix.net" => nil } }
      let(:template) do
        Class.new do
          include Jekyll::Imgix
        end.new
      end

      context 'development mode' do
        let(:url) { "https://google.com/cats.gif" }

        before do
          expect(Jekyll).to receive(:env).and_return("development")
        end

        describe 'passes values through' do
          it 'with no source specified' do
            expect(template.imgix_url(url)).to eq url
          end

          it 'with explicit source specified' do
            expect(template.imgix_url(url, 'assets2.imgix.net')).to eq url
          end
        end
      end

      context 'production mode' do
        let(:path) { "/cats.gif" }
        let(:config) do
          {
            'imgix' => {
              'sources' => sources,
            }
          }
        end
        let(:registers) do
          {
            site: double("Object", config: config)
          }
        end
        let(:context) {double("Object", registers: registers) }

        before do
          expect(Jekyll).to receive(:env).and_return("production")
          template.instance_variable_set(:@context, context)
        end

        describe 'passes values through' do
          it 'with no source specified' do
            expect {
              template.imgix_url(path)
            }.to raise_error(RuntimeError)
          end

          it 'with explicit source specified' do
            expect{
              template.imgix_url(path, 'assets2.imgix.net')
            }.not_to raise_error
          end

          it 'with unknown source specified' do
            expect {
              template.imgix_url(path, 'foo.bar')
            }.to raise_error(RuntimeError)
          end
        end

        describe 'adds parameters' do
          it 'with no source specified' do
            expect {
              template.imgix_url(path, { w: 400, h: 300 })
            }.to raise_error(RuntimeError)
          end

          it 'with explicit source specified' do
            expect {
              template.imgix_url(path, 'assets2.imgix.net', { w: 400, h: 300 })
            }.not_to raise_error
          end

          it 'with unknown source specified' do
            expect {
              template.imgix_url(path, 'foo.bar', { w: 400, h: 300 })
            }.to raise_error(RuntimeError)
          end
        end
      end
    end
  end

  context 'config validation' do
    let(:path) { "/cats.gif" }
    let(:source) { "assets.imgix.net" }
    let(:config) do
      {
        'imgix' => {
          'source' => source
        }
      }
    end

    let(:template) do
      Class.new do
        include Jekyll::Imgix
      end.new
    end
    let(:registers) do
      {
        site: double("Object", config: config)
      }
    end
    let(:context) {double("Object", registers: registers) }

    before do
      expect(Jekyll).to receive(:env).and_return("production")
      template.instance_variable_set(:@context, context)
    end

    context ':imgix not set in _config.yml' do
      let(:config) { {} }
      it 'raises an exception when :imgix is not present in _config.yml' do
        expect {
          template.imgix_url(path)
        }.to raise_error(StandardError, "No 'imgix' section present in _config.yml. Please see https://github.com/imgix/jekyll-imgix for configuration instructions")
      end
    end

    context ':source and :sources both set' do
      let(:config) { {
          'imgix' => {
          'source' => 'assets.imgix.net',
          'sources' => {
            'assets.imgix.net' => nil,
            'assets2.imgix.net' => nil,
          }
        }
      } }
      it 'raises an exception when :source and :source are both present in _config.yml' do
        expect {
          template.imgix_url(path)
        }.to raise_error(StandardError)
      end
    end

    context ':source and :source both not set' do
      let(:config) { { 'imgix': {} } }
      it 'raises an exception when :source and :source both are not present in _config.yml' do
        expect {
          template.imgix_url(path)
        }.to raise_error(StandardError)
      end
    end
  end
end

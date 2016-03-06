require 'spec_helper'

describe Jekyll::Imgix do
  let(:source) { "assets.imgix.net" }
  let(:template) do
    Class.new do
      include Jekyll::Imgix
    end.new
  end

  it 'has a version number' do
    expect(Jekyll::Imgix::VERSION).not_to be nil
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

      # We jump through these hoops because including the version number will
      # mess with the signature when the version number is incremented
      before do
        expect(template).to receive(:default_opts).and_return({
          host: source,
          include_library_param: false,
          use_https: true
        })
      end

      it 'signs the URL' do
        expect(template.imgix_url(path, { w: 400, h: 300 })).to eq "https://assets.imgix.net/cats.gif?w=400&h=300&s=e7e25321c9e007f36a8a4610662f32aa"
      end
    end

    context ':imgix not set in _config.yml' do
      let(:config) { {} }

      it 'raises an exception when :imgix is not present in _config.yml' do
        expect{ template.imgix_url(path) }.to raise_error(StandardError, "No 'imgix' section present in _config.yml. Please see https://github.com/imgix/jekyll-imgix for configuration instructions")
      end
    end
  end
end

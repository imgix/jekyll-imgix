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

    it 'adds parameters' do
      expect(template.imgix_url(path, { w: 400, h: 300 })).to eq "https://assets.imgix.net/cats.gif?ixlib=jekyll-#{Jekyll::Imgix::VERSION}&w=400&h=300"
    end

    context 'secure_url_token specified' do
      let(:config) do
        {
          'imgix' => {
            'source' => source,
            'secure_url_token' => "FACEBEEF"
          }
        }
      end

      # We jump through these hoops because including the version number will
      # mess with the signature when the version number get incremented
      before do
        expect(template).to receive(:default_opts).and_return({
          host: source,
          include_library_version: false,
          secure: true
        })
      end

      it 'signs the URL' do
        expect(template.imgix_url(path, { w: 400, h: 300 })).to eq "https://assets.imgix.net/cats.gif?ixlib=rb-0.3.5&w=400&h=300&s=8638dec97e477f1ff388113382e5b8bd"
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

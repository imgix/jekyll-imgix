require "jekyll/imgix/version"
require "imgix"
require "liquid"

module Jekyll
  module Imgix
    def imgix_url(raw, opts={})
      return raw unless production?
      verify_config_present!
      client.path(raw).to_url(opts)
    end

  private

    def verify_config_present!
      unless @context.registers[:site].config['imgix']
        raise StandardError.new("No 'imgix' section present in _config.yml. Please see https://github.com/imgix/jekyll-imgix for configuration instructions")
      end
    end

    def client
      return @client if @client

      opts = default_opts.dup
      opts[:token] = token if token
      @client = ::Imgix::Client.new(opts)
    end

    def default_opts
      {
        host: source,
        library_param: "jekyll",
        library_version: VERSION,
        secure: true
      }
    end

    def production?
      Jekyll.env == 'production'
    end

    def development?
      !production?
    end

    def source
      @context.registers[:site].config.fetch('imgix', {}).fetch('source', nil)
    end

    def token
      @context.registers[:site].config.fetch('imgix', {}).fetch('secure_url_token', nil)
    end
  end
end

Liquid::Template.register_filter(Jekyll::Imgix)

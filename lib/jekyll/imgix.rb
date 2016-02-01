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
      opts[:secure_url_token] = secure_url_token if secure_url_token
      opts[:include_library_param] = include_library_param?
      @client = ::Imgix::Client.new(opts)
    end

    def default_opts
      {
        host: source,
        library_param: "jekyll",
        library_version: VERSION,
        use_https: true
      }
    end

    def production?
      Jekyll.env == 'production'
    end

    def development?
      !production?
    end

    def ix_config
      @context.registers[:site].config.fetch('imgix', {})
    end

    def source
      ix_config.fetch('source', nil)
    end

    def secure_url_token
      ix_config.fetch('secure_url_token', nil)
    end

    def include_library_param?
      ix_config.fetch('include_library_param', true)
    end
  end
end

Liquid::Template.register_filter(Jekyll::Imgix)

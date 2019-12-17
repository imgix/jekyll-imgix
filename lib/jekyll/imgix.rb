require "jekyll/imgix/version"
require "imgix"
require "liquid"

module Jekyll
  module Imgix
    def imgix_url(*args)
      case args.size
      when 1
        path = args[0]
        source = nil
        options = {}
      when 2
        if args[0].is_a?(String) && args[1].is_a?(Hash)
          path = args[0]
          source = nil
          options = args[1]
        elsif args[0].is_a?(String) && args[1].is_a?(String)
          path = args[0]
          source = args[1]
          options = {}
        else
          raise RuntimeError.new("path and source must be of type String; options must be of type Hash")
        end
      when 3
        path = args[0]
        source = args[1]
        options = args[2]
      else
        raise RuntimeError.new('path missing')
      end

      return path unless production?

      verify_config!
      imgix_client(source).path(path).to_url(options)
    end

  private

    DEFAULT_OPTS = {
      library_param: "jekyll",
      library_version: VERSION,
      use_https: true
    }.freeze


    def verify_config!
      config = @context.registers[:site].config['imgix']
      unless config
        raise StandardError.new("No 'imgix' section present in _config.yml. Please see https://github.com/imgix/jekyll-imgix for configuration instructions")
      end
      if !(config['source'] || config['sources'])
        raise StandardError.new("One of 'source', 'sources' is required")
      end
      if (config['source'] && config['sources'])
        raise StandardError.new("'source' and 'sources' can't be used together")
      end
    end

    def imgix_client(src)
      begin
        return imgix_clients.fetch(src)
      rescue KeyError
        raise RuntimeError.new("Unknown source '#{src}'")
      end
    end

    def imgix_clients
      return @imgix_clients if @imgix_clients

      opts = DEFAULT_OPTS.dup
      opts[:secure_url_token] = secure_url_token if secure_url_token
      opts[:include_library_param] = include_library_param?

      @imgix_clients = {}
      sources.map do |source, token|
        opts[:host] = source
        opts[:secure_url_token] = token
        @imgix_clients[source] = ::Imgix::Client.new(opts)
      end

      begin
        @imgix_clients[nil] = @imgix_clients.fetch(default_source || source)
      rescue
      end

      @imgix_clients
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

    def sources
      begin
        return ix_config.fetch('sources')
      rescue
        return { ix_config.fetch('source') => secure_url_token }
      end
    end

    def default_source
      ix_config.fetch('default_source', nil)
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

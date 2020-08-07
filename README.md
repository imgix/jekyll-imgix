<!-- ix-docs-ignore -->
![imgix logo](https://assets.imgix.net/sdk-imgix-logo.svg)

`jekyll-imgix` is a plugin for integrating [imgix](https://www.imgix.com) into Jekyll sites.

[![Gem Version](https://img.shields.io/gem/v/jekyll-imgix.svg)](https://rubygems.org/gems/jekyll-imgix)
[![Build Status](https://travis-ci.org/imgix/jekyll-imgix.svg)](https://travis-ci.org/imgix/jekyll-imgix)
![Downloads](https://img.shields.io/gem/dt/jekyll-imgix)
[![License](https://img.shields.io/github/license/imgix/drift)](https://github.com/imgix/jekyll-imgix/blob/main/LICENSE)

---
<!-- /ix-docs-ignore -->

- [Installation](#installation)
- [Configuration](#configuration)
  - [Multi-source configuration](#multi-source-configuration)
- [Usage](#usage)
  - [Multi-source usage](#multi-source-usage)
- [Contributing](#contributing)
- [Code of Conduct](#code-of-conduct)

## Installation

First, add `liquid` and `jekyll-imgix` to the `:jekyll_plugins` group in your Gemfile:

```rb
group :jekyll_plugins do
  gem 'rouge'
  gem 'kramdown'
  gem 'liquid'
  gem 'jekyll-imgix'
end
```

Then include `jekyll-imgix` in the `plugins:` section of your `_config.yml` file:

``` yaml
plugins: [jekyll/imgix]
```

## Configuration

jekyll-imgix requires a configuration block in your `_config.yml`:

```yaml
imgix:
  source: assets.imgix.net # Your imgix source address
  secure_url_token: FACEBEEF12 # (optional) The Secure URL Token associated with your source
  include_library_param: true  # (optional) If `true` all the URLs will include `ixlib` parameter
```

### Multi-source configuration

In addition to the standard configuration flags, the following options can be used to serve images across different sources.

```yaml
imgix:
  sources:  # imgix source-secure_url_token key-value pairs.
    assets.imgix.net: FACEBEEF12
    assets2.imgix.net:            # Will generate unsigned URLs
  default_source: assets.imgix.net  # (optional) specify a default source for generating URLs.
```

Note: `sources` and `source` *cannot* be used together.

## Usage

**jekyll-imgix does not do anything unless JEKYLL_ENV is set to production**. For example,
you will want to run `JEKYLL_ENV=production jekyll build` before deploying your site to
production.

jekyll-imgix exposes its functionality as a single Jekyll Filter, `imgix_url`.

Pass an existing image path to it to activate it:

```html
<img src={{ "/images/bear.jpg" | imgix_url }} />
```

That will generate the following HTML in your output:

```html
<img src="https://assets.imgix.net/images/bear.jpg" />
```

You can also pass parameters to the `imgix_url` helper like so:

```html
<img src={{ "/images/bear.jpg" | imgix_url: w: 400, h: 300 }} />
```

Which would result in the following HTML:

```html
<img src="https://assets.imgix.net/images/bear.jpg?w=400&h=300" />
```

### Multi-source usage

To use jekyll-imgix in a multi-source setup:

```html
<img src={{ "/images/bear.jpg" | imgix_url: "assets2.imgix.net", w: 400, h: 300 }} />
<img src={{ "/images/bear.jpg" | imgix_url: w: 400, h: 300 }} />  <!-- will use default_source from config -->
```

Which would generate:

```html
<img src="https://assets2.imgix.net/images/bear.jpg?w=400&h=300" />
<img src="https://assets.imgix.net/images/bear.jpg?w=400&h=300" />
```

In absence of correctly configured `default_source`, `imgix_url` will report `RuntimeError` if it's used without specifying a valid source.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/imgix/jekyll-imgix.

## Code of Conduct
Users contributing to or participating in the development of this project are subject to the terms of imgix's [Code of Conduct](https://github.com/imgix/code-of-conduct).

# jekyll-imgix ![Travis Build Status](https://travis-ci.org/imgix/jekyll-imgix.svg)

A simple Jekyll plugin for rolling imgix functionality into your Jekyll site.

## Installation

First, add `liquid` and `jekyll-imgix` to the `:jekyll_plugins` group in your Gemfile:

``` ruby
group :jekyll_plugins do
  gem 'rouge'
  gem 'kramdown'
  gem 'liquid'
  gem 'jekyll-imgix'
end
```

Then include `jekyll-imgix` in the `gems:` section of your `_config.yml` file:

``` yaml
gems: [jekyll/imgix]
```

## Usage

**jekyll-imgix does not do anything unless JEKYLL_ENV is set to production**. For example,
you will want to run `JEKYLL_ENV=production jekyll build` before deploying your site to
production.

jekyll-imgix exposes its functionality as a single Jekyll Filter, `imgix_url`.

Simply pass an existing image path to it to activate it:

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

### Configuration

jekyll-imgix requires a configuration block in your `_config.yml`:

```yaml
imgix:
  source: assets.imgix.net # Your imgix source address
  secure_url_token: FACEBEEF12 # (optional) The Secure URL Token associated with your source
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/imgix/jekyll-imgix.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


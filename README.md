# Orchparty::Rancher

[![Build Status](https://travis-ci.org/jannishuebl/orchparty.svg?branch=master)](https://travis-ci.org/pschrammel/orchparty-rancher)
[![Gem Version](https://badge.fury.io/rb/orchparty.svg)](https://badge.fury.io/rb/orchparty-rancher)

This is a [Orchparty](https://orch.party/) plugin to generate
docker-compose.yml and rancher-compose.yml files.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'orchparty-rancher'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install orchparty-rancher

## Usage

Add a rancher section to your stack description:

```
application "test" do
  service "web" do
    image 'mywebservice/webservice'
    rancher do
     scale 3
     upgrade_strategy do
       _ start_first: true
       _ interval_millis: 30000
     end
     health_check do
       _ healthy_threshold: 2
       _ initializing_timeout: 60000
       _ interval: 30000
       _ port: 4000
       _ request_line: "GET / HTTP/1.1"
       _ response_timeout: 3000
       _ strategy: 'recreate'
       _ unhealthy_threshold: 3
     end  
    end 
  end
```

Run orchparty with the rancher_v2 generator:
```ruby
orchparty generate rancher_v2 -f stack.rb -d docker-compose.yml -r rancher-compose.yml
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/pschrammel/orchparty-rancher.


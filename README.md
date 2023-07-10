# Pollen

**🚧 work in progress 🚧**

Pub/Sub for Ruby on Rails on a modular monolithic architecture using `ActiveSupport::Notifications`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pollen'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pollen

## Concepts
### No additional middleware

No additional middleware is required to use this feature, it just works with what Rails has.

### Type checking

Instead of just passing a Hash, the value is passed through a specific schema.

### Easy to investigate

Usually publishers don't care who is subscribing. 
However, if you want to find out, you can easily do so by simply grep'ing the application code. There is no implicit mapping.

## Usage

```ruby
# packs/common/app/messages/post_created_message.rb
class PostCreatedMessage < Pollen::Message
  attribute :id, :integer, required: true
  attribute :title, :string, required: true
  attribute :body, :string
end
```

```ruby
# packs/post/app/models/post.rb
class Post < ApplicationRecord
  after_create do
    PostCreatedPublisher.publish!(
      PostCreatedMessage.new(id: id, title: title, body: body)
    )
  end
end
```

```ruby
# packs/post/app/publishers/post_created_publisher.rb
class PostCreatedPublisher < Pollen::Publisher
  use_message PostCreatedMessage

  # @param [PostCreatedMessage] message
  def self.publish!(message)
    super 
    puts 'published!'
  end
end
```

```ruby
# packs/user/app/subscribers/user_profile_post_subscriber.rb
class UserProfilePostSubscriber < Pollen::Subscriber
  use_message PostCreatedMessage
  
  # @param [PostCreatedMessage] message
  def self.subscribe!(message)
    UpdatePostCountJob.perform_later(message.id)
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pollen. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Pollen project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/pollen/blob/master/CODE_OF_CONDUCT.md).

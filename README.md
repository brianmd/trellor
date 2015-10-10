# Trellor

Terminal interface to Trello.

## Installation

    $ gem install trellor

Three environment variables need to be set: TRELLOR_KEY, TRELLOR_TOKEN,
    and TRELLOR_USERNAME

    TRELLOR_KEY comes from your developer public key at:
    https://trello.com/1/appKey/generate
    (note: also copy the develop api key for the next step)

    TRELLOR_TOKEN is the member token found at:
    https://trello.com/1/authorize?key=YOUR_DEVELOPER_API_KEY&name=trellor&expiration=never&response_type=token&scope=read,write

    TRELLOR_USERNAME is your username

## Usage

    $ trellor -h     # prints help
    $ trellor        # prints all board names
    $ trellor        # caches all boards and lists to ~/.config/.trellor
                     # toying with using this to speed access
                     # however, the connection seems to be main slowdown
    $ trellor to     # prints all list names inside the first board with name
                     # beginning with 'to' (case insensitive)
                     # for example, this matches 'ToDo'
    $ trellor to in  # prints all card names in the list named 'in*' in board
                     # named 'to*', e.g., matches 'ToDo.Inbox'
    # create a card:
    $ trellor to in 'this is a new card', 'this is an optional description.'

    Using aliases work well, for example:
    $ alias inbox="trellor todo inbox"
    $ inbox               # prints cards in todo.inbox
    $ inbox 'new card'    # creates a new card in todo.inbox

Starting with version 2, a webapp is run in the background. Making the connection to
Trello resulted in over half the time to run a command. The local webapp pays
this cost only once.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/trellor.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


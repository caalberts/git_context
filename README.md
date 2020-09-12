# git-context

[![CircleCI Status](https://circleci.com/gh/caalberts/git_context/tree/master.svg?style=svg)](https://circleci.com/gh/caalberts/git_context/tree/master)
[![codecov](https://codecov.io/gh/caalberts/git_context/branch/master/graph/badge.svg)](https://codecov.io/gh/caalberts/git_context)

`git-context` provides a tool to manage conditional git config.

No more committing with the wrong email in a new repository. With `git-context` you can set up a context per directory. Any git repositories within the directory would use the git config specified for that directory.

Currently, the supported config values are:
- `user.name`
- `user.email`

`git-context` uses git config [conditional includes](https://git-scm.com/docs/git-config#_conditional_includes) under the hood.

## Installation

Install the `git-context` CLI via `gem install`.

```shell
    $ gem install git_context
```
## Usage

First, set up `git-context` to hook into the user's `~/.git/config`.

```shell
    $ git-context setup
```

Next, create one or more user profile to contain the user name and email address.

```shell
    $ git-context create_profile
    Please enter profile name: work
    Please enter the name to be used in git config: John Doe
    Please enter the email address to be used in git config: johndoe@company.com
    Please enter the signing key to be used in git config: ABCD1234

    $ git-context create_profile
    Please enter profile name: fun
    Please enter the name to be used in git config: Johnny
    Please enter the email address to be used in git config: johnny@wut.lol
    Please enter the signing key to be used in git config: ZYXV0987
```

Finally, create contexts to use a specified profile in a directory.

```shell
    $ git-context create_context
    Please enter working directory: /Users/john/work
    Please select from existing profiles: work
    
    $ git-context create_context
    Please enter working directory: /Users/john/fun
    Please select from existing profiles: fun
```

Now you can commit as different users easily.

```shell
    $ cd /Users/john/work/project/unicorn
    $ git config user.name
    John Doe
    $ git config user.email
    johndoe@company.com
    $ git config user.signingKey
    ABCD1234
    
    $ cd /Users/john/fun/lol/wut
    $ git config user.name
    Johnny
    $ git config user.email
    johnny@wut.lol
    $ git config user.signingKey
    ZYXV0987
```

**Tip:** You could also use `git context`. `git` recognizes `git-context` as a custom command. 

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/caalberts/git_context.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

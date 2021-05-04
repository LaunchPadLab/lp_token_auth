[![Documentation](http://img.shields.io/badge/docs-rdoc.info-blue.svg)](http://www.rubydoc.info/github/LaunchPadLab/lp_token_auth)
[![Build Status](https://travis-ci.org/LaunchPadLab/lp_token_auth.svg?branch=master)](https://travis-ci.org/LaunchPadLab/lp_token_auth)
[![Test Coverage](https://codeclimate.com/repos/593aabffc759c90269001912/badges/1e40a4f9bc94a46fc508/coverage.svg)](https://codeclimate.com/repos/593aabffc759c90269001912/coverage)
[![Code Climate](https://codeclimate.com/repos/593aabffc759c90269001912/badges/1e40a4f9bc94a46fc508/gpa.svg)](https://codeclimate.com/repos/593aabffc759c90269001912/feed)

# LP Token Auth
Simple token authentication logic with JWTs for Rails apps. No baked in routing, just the barebones logic you need to implement token authentication with JWTs.

* [Installation](#installation)
* [Usage](#usage)
* [Examples](#examples)
* [Migration Guide](#migration-guide)

## Installation
Add this line to your application's Gemfile:

`gem 'lp_token_auth'`

And then execute:

`$ bundle`

Or install it yourself as:

`$ gem install lp_token_auth`

## Usage
1. Run `bundle exec rails generate lp_token_auth:install` to generate an initializer at `../config/initalizers/lp_token_auth.rb`. See the initializer for more details about what is configurable.
2. In the most senior controller that you want to authenticate, add `include LpTokenAuth::Controller`. This gives you 4 methods that are available in this and all child controllers:
  + `login(user)` - Given a valid user, this will generate a JWT and return it. The token should be sent to the client and passed in the 'Authorization' header in all subsequent requests to the server.
  + `authenticate_request!` - This is a `before_action` to use in your controllers that will extract the token from the header and authenticate it before proceeding. If the resource class that you're using is not the default `User`, you may override the `authenticate_request!` method by creating a custom `before_action`, in which you may pass in the resource class name.

  ```
    class AuthenticationController < ApplicationController
      include LpTokenAuth::Controller

      before_action :authenticate_request

      protected

      def authenticate_request
        authenticate_request!('AdminUser')
      end
    end
  ```
  + `authenticate_token!(token)` - This is called by `authenticate_request!` but is available to use if you ever need to manually authenticate a token.
  + `current_user` - This returns the current user identified by `authenticate!`. It is available after logging in the user or authenticating.
3. All errors will return an instance of `LpTokenAuth::Error`

## Migration Guide
[Migration Guide](https://github.com/LaunchPadLab/lp_token_auth/blob/master/migration-guide.md)

## Examples
### Controller
```
class AuthenticatingController < ApplicationController
  include LpTokenAuth::Controller

  before_action :authenticate_request!

  rescue_from LpTokenAuth::Error, with: :unauthorized

  protected

  def unauthorized(error)
    render json: { data: error.message }, status: :unauthorized
  end
end
```

### Api Request
```
// Using fetch api
const jwt = '...'
fetch('localhost:3000/authenticated-route', {
  headers: {
    'Authorization': `Bearer ${jwt}`
    ...
  }
  ...
})
```

## Development
+ `git clone git@github.com:LaunchPadLab/lp_token_auth.git`
+ `bundle install`

### Testing
+ Run tests with `rake`

## FAQ

### Can I use this without ActiveRecord?

Almost! There is a slight dependence on the ActiveRecord method `find`, which is used in order to decode a token based on the resource's `id`. The current workaround is to make sure the resource class you're using implements `find`, and has either a column `id` or implements a method called `id`.

## Authenticate away!

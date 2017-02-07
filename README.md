# LP Token Auth
Simple token authentication logic with JWTs for Rails apps. No baked in routing, just the barebones logic you need to implement token authentication with JWTs.

## Installation
Add `gem lp_token_auth, git: 'https://github.com/launchpadlab/lp_token_auth.git',` to your Gemfile and run `bundle install`.

## Usage
For the purposes of these instructions, I will assume the model you are using is 'User' but it could be anything you want.

1. Generate a migration to add the required fields to the model of your choice with `bundle exec rails generate lp_token_auth:model User`
2. Run the migration with `bundle exec rails db:migrate`. This adds three columns to your table: `confirmation_token`, `confirmed_at`, and `confirmation_sent_at`.
3. When you want to start the process, assume you have created a `user`, then call `LpTokenAuth::Model.set_confirmation_token! user`. This will return the token that you can share with the client via email, link, smoke-signals, whatever.
4. While you are in charge of sending confirmation instructions, `lp_token_auth` still needs to track it, so when you are ready call
```
LpTokenAuth::Model.send_confirmation_instructions! user do
    <insert your logic here>
end
```
and 'lp_token_auth' will take care of the rest.

5. To confirm a user, call `LpTokenAuth::Model.confirm_by_token!(User, confirmation_token)`. This will find the user by confirmation token and confirm them, returning the user model.
6. Any errors that pop up along the way, such as trying to confirm a non-confirmable object, or an expired token, etc..., will throw an `LpTokenAuth::Error`.
7. To change the global defaults run `bundle exec rails generate lp_token_auth:install` to generate an initializer at `../config/initalizers/lp_token_auth.rb`. See the initializer for more details.

## Development
+ `git clone git@github.com:LaunchPadLab/lp_token_auth.git`
+ `bundle install`
+ Test with `rake`

## Confirm away!

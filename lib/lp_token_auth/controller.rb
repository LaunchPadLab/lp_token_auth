require 'lp_token_auth/core'

module LpTokenAuth
  module Controller
    def login(user)
      token = LpTokenAuth.issue_token(user.id)
      authenticate! token
      token
    end

    def authenticate_request!
      token = request.headers.fetch('Authorization', '').split(' ').last
      authenticate! token
    end

    def authenticate!(token)
      decoded = LpTokenAuth.decode!(token)
      @current_user = User.find(decoded['id'])
    end

    def current_user
      @current_user
    end
  end
end

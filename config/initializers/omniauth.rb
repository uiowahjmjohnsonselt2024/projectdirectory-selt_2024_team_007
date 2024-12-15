# OAuth Middleware
OmniAuth.config.logger = Rails.logger
OmniAuth.config.request_validation_phase = nil
OmniAuth.config.allowed_request_methods = [:post]


Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'], {
    scope: 'email,profile',
    redirect_uri: "#{Rails.env.production? ? 'https' : 'http'}://#{ENV['HOST_URL']}/auth/google_oauth2/callback"
  }
end



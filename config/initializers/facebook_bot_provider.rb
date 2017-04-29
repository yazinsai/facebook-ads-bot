class FBConfigProvider < Facebook::Messenger::Configuration::Providers::Base
  def valid_verify_token?(verify_token)
    Rails.configuration.fb.messenger.verify_token == verify_token
  end

  def app_secret_for(page_id) # we've only got one, so ignored
    Rails.configuration.fb.messenger.secret_token
  end

  def access_token_for(page_id)
    Rails.configuration.fb.messenger.access_token
  end
end

Facebook::Messenger.configure do |config|
  config.provider = FBConfigProvider.new
end
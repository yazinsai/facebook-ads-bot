# bot.rb
require 'facebook/messenger'

include Facebook::Messenger

Facebook::Messenger::Profile.set({
  greeting: {
    locale: 'default',
    text: 'Welcome to your friendly Ads Bot! :)' 
  },
  get_started: {
    payload: 'GET_STARTED' # make sure to handle this postback
  }
  # @TODO: Add persistent menu
}, access_token: Rails.configuration.fb.messenger.access_token)

Bot.on :message do |message|
  message.id          # => 'mid.1457764197618:41d102a3e1ae206a38'
  message.sender      # => { 'id' => '1008372609250235' }
  message.seq         # => 73
  message.sent_at     # => 2016-04-22 21:30:36 +0200
  message.text        # => 'Hello, bot!'
  message.attachments # => [ { 'type' => 'image', 'payload' => { 'url' => 'https://www.example.com/1.jpg' } } ]

  message.reply(
      attachment: {
        type: 'template',
        payload: {
          template_type: 'button',
          text: 'Human, do you like me?',
          buttons: [
            { type: 'postback', title: 'Yes', payload: 'HARMLESS' },
            { type: 'postback', title: 'No', payload: 'EXTERMINATE' }
          ]
        }
      }
    )
end

Bot.on :postback do |postback|
  postback.sender    # => { 'id' => '1008372609250235' }
  postback.recipient # => { 'id' => '2015573629214912' }
  postback.sent_at   # => 2016-04-22 21:30:36 +0200
  postback.payload   # => 'EXTERMINATE'

  if postback.payload == 'EXTERMINATE'
    Bot.deliver({
        recipient: postback.sender,
        message: { text: 'Human?' }
    }, access_token: Rails.configuration.fb.messenger.access_token)
  end
end
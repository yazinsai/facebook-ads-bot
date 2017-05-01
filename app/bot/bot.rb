require 'facebook/messenger'
include Facebook::Messenger

# Bot Sequence:
# - title, text
# - message, text
# - link, options (website, app)
# - image, image
# - budget, image list (small, medium, large)
# - confirmation
# - done
class AdBot
  @@states = [:initial, :title_asked, :message_asked, :link_asked, :image_asked, 
                :budget_asked, :confirmation_asked].freeze
  attr_reader :title, :message, :link, :image, :budget

  def initialize
    @state = 0
    @last_message, @last_postback = nil, nil
    
    # setup_bot
    Bot.on(:message){ |msg| receive_message(msg) }
    Bot.on(:postback){ |postback| receive_postback(postback) }
  end
  
  private
  
  # Sets up the initial options for our friendly bot
  def setup_bot
    Facebook::Messenger::Profile.set({
      greeting: {
        locale: 'default',
        text: 'Welcome to your friendly Ads Bot! :)' 
      },
      get_started: {
        payload: 'GET_STARTED' # make sure to handle this postback
      }
      # @TODO: Add persistent menu
    }, access_token: access_token)
  end
  
  # Shortcut, since we use the access token alot
  def access_token
    Rails.configuration.fb.messenger.access_token
  end
  
  def state
    @@states[@state]
  end
  
  # Gets called whenever we receive a typed message from the user
  def receive_message(message)
    # message.id => 'mid.1457764197618:41d102a3e1ae206a38'
    # message.sender => { 'id' => '1008372609250235' }
    # message.seq => 73
    # message.sent_at => 2016-04-22 21:30:36 +0200
    # message.text => 'Hello, bot!'
    # message.attachments => [{ 
    #         'type' => 'image', 
    #         'payload' => { 
    #           'url' => 'https://www.example.com/1.jpg' }}]
    Rails.logger.debug "receive_message()"
    Rails.logger.debug "text = #{message.text.inspect}"
    Rails.logger.debug "attachments = #{message.attachments.inspect}"
    Rails.logger.debug "state = " + state.to_s
    
    # Store reference to this message
    @last_message = message
    
    # handle response by state
    case state
    when :initial      # greeting
      ask_for_title
    when :title_asked    # received title, ask for message
      @title = message.text
      ask_for_message
    when :message_asked  # received message, ask for link
      @message = message.text
      ask_for_link
    when :link_asked     # ⚠️ exception (expecting postback)
    when :image_asked    # received image, ask for budget
      @image = message.attachments[0]['payload']['url']
      ask_for_budget
    when :budget_asked   # ⚠️ exception (expecting postback)
    end
    
    @state += 1 # advance to next state
  end
  
  # Gets called whenever we receive a callback from the user (e.g. clicked a
  # choice from a template menu, button, etc.)
  def receive_postback(postback)
    # postback.sender => { 'id' => '1008372609250235' }
    # postback.recipient => { 'id' => '2015573629214912' }
    # postback.sent_at => 2016-04-22 21:30:36 +0200
    # postback.payload => 'EXTERMINATE'
    Rails.logger.debug "receive_postback()"
    Rails.logger.debug "payload = #{postback.payload}"
    Rails.logger.debug "state = " + state.to_s
    
    # Store reference to this postback
    @last_postback = postback
    
    case state
    when :link_asked
      ad_config = Rails.configuration.fb.ad
      @link = (postback.payload == "LINK-WEBSITE" ? 
                ad_config.website : ad_config.app)
      ask_for_image
    when :budget_asked
      match = postback.payload.match(/^BUDGET-(\d+)$/i)
      @budget = match.captures.first.to_i * 100 # BUDGET-50 -> 5000 (in cents)
      ask_for_confirmation
    when :confirmation_asked
      if postback.payload == "CONFIRM-YES"
        create_ad
      else
        @state = 0
        ask_for_title
      end
    end
    
    @state += 1
  end
  
  # Questions
  def ask_for_title
    @last_message.reply(text: "Hey there! 👋")
    @last_message.reply(text: "My name's AdBot. I'm here to help you create an ad today")
    wait
    @last_message.reply(text: "Let's get a title for the new ad")
  end
  
  def ask_for_message
    @last_message.reply(text: "Awesome! Now, let's put down a message for the new ad.")
    @last_message.reply(text: "Try to keep it short. An example might be: ")
    wait
    @last_message.reply(text: "This new breakfast cereal will morph you into a coding ninja!")
    wait
    @last_message.reply(text: "Your turn.")
  end
  
  def ask_for_link
    @last_message.reply(text: "Nice one!")
    wait
    @last_message.reply(
      attachment: {
        type: 'template',
        payload: {
          template_type: 'button',
          text: 'Where would you like the ad to link?',
          buttons: [
            { type: 'postback', title: 'My Website', payload: 'LINK-WEBSITE' },
            { type: 'postback', title: 'My App', payload: 'LINK-APP' }
          ]
        }
      })
  end
  
  def ask_for_image
    @last_message.reply(text: "Nicely done! Now let's get a photo for the ad.")
    wait
    @last_message.reply(text: "You can snap one with your camera 📸  or just pick one you've already taken.")
  end
  
  def ask_for_budget
    @last_message.reply(text: "Brilliant. Just one more step to go!")
    wait
    @last_message.reply(text: "We need you to confirm the budget for this ad. How much do you want to spend?")
    wait 2
    @last_message.reply(
      attachment: {
        type: 'template',
        payload: {
          template_type: 'list',
          top_element_style: "compact",
          elements: [
            {
              title: "Small",
              image_url: "https://cdn1.iconfinder.com/data/icons/payment-icons/64/Gold_Coin_-_Single.png",
              subtitle: "Ideal for testing",
              buttons: [{
                type: "postback",
                title: "$50",
                payload: "BUDGET-50"
              }]
            },
            {
              title: "Medium",
              image_url: "https://cdn1.iconfinder.com/data/icons/payment-icons/64/Gold_Coin_-_Stacks.png",
              subtitle: "Standard ad",
              buttons: [{
                type: "postback",
                title: "$500",
                payload: "BUDGET-500"
              }]
            },
            {
              title: "Large",
              image_url: "https://cdn1.iconfinder.com/data/icons/payment-icons/64/Cash.png",
              subtitle: "Go big, or go home",
              buttons: [{
                type: "postback",
                title: "$50,000",
                payload: "BUDGET-50000"
              }]
            }
          ]
        }
      }
      )
  end
  
  def ask_for_confirmation
    wait
    @last_message.reply(text: "Before I send this off to my robot friends at Facebook, let's make sure it's all ok.")
    wait
    @last_message.reply(text: "Here's what I got so far:")
    wait
    @last_message.reply(text: "✅  Title: #{@title}")
    @last_message.reply(text: "✅  Message: #{@message}")
    @last_message.reply(text: "✅  Link: #{@link}")
    @last_message.reply(text: "✅  Budget: $#{@budget/100}")
    wait 2
    @last_message.reply(text: "Oh, and here's your lovely image:")
    @last_message.reply(
      attachment: {
        type: 'image',
        payload: { url: @image }
      })
    wait 2
    @last_message.reply(
      attachment: {
        type: 'template',
        payload: {
          template_type: 'button',
          text: 'Does that look good?',
          buttons: [
            { type: 'postback', title: "Yes, launch ad!", payload: 'CONFIRM-YES' },
            { type: 'postback', title: 'No', payload: 'CONFIRM-NO' }
          ]
        }
      })
  end
  
  def wait(how_much = 1)
    sleep(how_much)
  end
  
  # Uses the class instance variables (title, message, link, image, budget) to create
  # the ad
  def create_ad
    created_ad = nil
    thread = Thread.new do
      ctrl = PagesController.new
      created_ad = ctrl.create_ad(title: @title, message: @message, 
                      link: @link, image: @image, budget: @budget)
    end
    
    @last_message.reply(text: "Ok, I'm going to talk to Facebook now ⏳")
    wait 5
    @last_message.reply(text: "While we're waiting, let me find a cat picture for you")
    wait 3
    @last_message.reply(text: "Ah, here's one!")
    @last_message.reply(
      attachment: {
        type: 'image',
        payload: { url: "http://www.top13.net/wp-content/uploads/2015/10/perfectly-timed-funny-cat-pictures-5.jpg" }
      })
    wait 3
    @last_message.reply(text: "Almost done now")
    thread.join # make sure it's done
    @last_message.reply(text: "Ah, all done! You're now the proud owner of ad ##{created_ad}")
    @last_message.reply(text: "Thanks for dropping by. See you later!")
  end
end

# Instantiate our AdBot
AdBot.new
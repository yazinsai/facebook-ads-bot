class PagesController < ApplicationController
    def main
        facebook_init
        render plain: "done"
    end
    
    private
    
    def facebook_init
        fb_marketing
        fb_messenger
    end
    
    private
    
    def fb_marketing
        FacebookAds.access_token = Rails.configuration.fb.marketing.access_token
        FacebookAds.base_uri = 'https://graph.facebook.com/v2.9'
        
        accounts = FacebookAds::AdAccount.all
    end
    
    def fb_messenger
        require 'facebook/messenger'
        include Facebook::Messenger
        
        # needs these ENV variables:
        # ---
        # export ACCESS_TOKEN=EAAAG6WgW...
        # export APP_SECRET=a885a...
        # export VERIFY_TOKEN=95vr15g...
    end
end

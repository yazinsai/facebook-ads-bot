class PagesController < ApplicationController
    def main
        render plain: facebook_init
    end
    
    def facebook_init
        fb_impressions
    end
    
    private
    
    def fb_marketing
        config = Rails.configuration.fb.marketing
        
        FacebookAds.access_token = config.access_token
        FacebookAds.base_uri = 'https://graph.facebook.com/v2.9'
        FacebookAds.logger = logger
        
        # To list all accounts, you can simply do:
        #   accounts = FacebookAds::AdAccount.all
        
        account = FacebookAds::AdAccount.find(config.account_id)
        
        # 1. Create a campaign
        campaign = account.create_ad_campaign(
            name: 'Test Campaign',
            objective: 'BRAND_AWARENESS',
            status: 'PAUSED')
        
        # To retrieve a list of all campaigns, just do:
        #   campaigns = account.ad_campaigns(effective_status: nil)
        
        # 2. Add an image
        ad_images = account.create_ad_images(["https://static.pexels.com/photos/4825/red-love-romantic-flowers.jpg", "https://static.pexels.com/photos/36753/flower-purple-lical-blosso.jpg"])
        
        # To retrieve a list of all ad images, you can do:
        # ad_images = account.ad_images
        
        # 3. Create an Ad Creative
        ad_creative = account.create_ad_creative({
            name: 'Test Carousel Creative',
            page_id: config.page_id,
            link: 'http://c9users.io/',
            message: 'A message.',
            assets: [
                { hash: ad_images.first.hash, title: 'Image #1 Title' },
                { hash: ad_images.second.hash, title: 'Image #2 Title' }],
            call_to_action_type: 'SHOP_NOW',
            multi_share_optimized: true,
            multi_share_end_card: false
            }, carousel: true)
        
        # To retrieve a list of all ad creative, just do:
        #   ad_creatives = account.ad_creatives
        
        # 4. Create an Ad Set for a Campaign
        
        # - a. First, create your targeting
        targeting = FacebookAds::AdTargeting.new
        targeting.excluded_connections = [config.page_id]
        
        # - b. Create the ad set
        ad_set = campaign.create_ad_set(
            name: 'Test Ad Set',
            targeting: targeting,
            promoted_object: {
                page_id: config.page_id },
            optimization_goal: 'BRAND_AWARENESS',
            daily_budget: 25000, # in cents
            billing_event: 'IMPRESSIONS',
            status: 'PAUSED')
        
        # To retrieve a list of all ad sets, you do:
        #   ad_sets = campaign.ad_sets(effective_status: nil)
        
        # 5. Create the Ad (finally!)
        # We'll need:
        # - an ad_set
        # ad_set = campaign.ad_sets(effective_status: nil).first
        # - an ad_creative
        # ad_creative = account.ad_creatives.first
        # .. mix thouroughly:
        ad = ad_set.create_ad(
            name: 'Test Ad', creative_id: ad_creative.id, status: 'PAUSED')
        
        # To retrieve a list of all ads, we could do:
        #   ads = ad_set.ads
    end
    
    def fb_impressions
        config = Rails.configuration.fb.marketing
        
        FacebookAds.access_token = config.access_token
        FacebookAds.base_uri = 'https://graph.facebook.com/v2.9'
        FacebookAds.logger = logger
        
        # Find our account
        account = FacebookAds::AdAccount.find(config.account_id)
        
        # 1. Create a campaign
        campaign = account.create_ad_campaign(
            name: 'Test Campaign',
            objective: 'BRAND_AWARENESS',
            status: 'PAUSED')
        
        # 2. Add an image
        ad_images = account.create_ad_images(["https://static.pexels.com/photos/4825/red-love-romantic-flowers.jpg", "https://static.pexels.com/photos/36753/flower-purple-lical-blosso.jpg"])
        
        # 3. Create an Ad Creative
        ad_creative = account.create_ad_creative({
            name: 'Test Carousel Creative',
            page_id: config.page_id,
            link: 'http://c9users.io/',
            message: 'A message.',
            assets: [
                { hash: ad_images.first.hash, title: 'Image #1 Title' },
                { hash: ad_images.second.hash, title: 'Image #2 Title' }],
            call_to_action_type: 'SHOP_NOW',
            multi_share_optimized: true,
            multi_share_end_card: false
            }, carousel: true)
        
        # 4. Create an Ad Set for a Campaign
        # - a. First, create your targeting
        targeting = FacebookAds::AdTargeting.new
        targeting.genders = [FacebookAds::AdTargeting::WOMEN]
        targeting.age_min = 29
        targeting.age_max = 65
        targeting.countries = ['GB']
        
        # - b. Create the ad set
        ad_set = campaign.create_ad_set(
            name: 'Test Ad Set',
            targeting: targeting,
            promoted_object: {
                page_id: config.page_id },
            optimization_goal: 'BRAND_AWARENESS',
            daily_budget: 25000, # in cents
            billing_event: 'IMPRESSIONS',
            status: 'PAUSED')
        
        # 5. Create the Ad (finally!)
        ad = ad_set.create_ad(
            name: 'Test Ad', creative_id: ad_creative.id, status: 'PAUSED')
    end
    
    def fb_page_clicks
        config = Rails.configuration.fb.marketing
        
        FacebookAds.access_token = config.access_token
        FacebookAds.base_uri = 'https://graph.facebook.com/v2.9'
        FacebookAds.logger = logger
        
        account = FacebookAds::AdAccount.find(config.account_id)
        
        # 1. Create a campaign
        campaign = account.create_ad_campaign(
            name: 'Test Campaign',
            objective: 'PAGE_LIKES',
            status: 'PAUSED')
        
        # 2. Add an image
        ad_images = account.create_ad_images(["https://static.pexels.com/photos/4825/red-love-romantic-flowers.jpg", "https://static.pexels.com/photos/36753/flower-purple-lical-blosso.jpg"])
        
        # 3. Create an Ad Creative
        ad_creative = account.create_ad_creative({
            name: 'Test Carousel Creative',
            page_id: config.page_id,
            link: 'http://c9users.io/',
            message: 'A message.',
            assets: [
                { hash: ad_images.first.hash, title: 'Image #1 Title' },
                { hash: ad_images.second.hash, title: 'Image #2 Title' }],
            call_to_action_type: 'SHOP_NOW',
            multi_share_optimized: true,
            multi_share_end_card: false
            }, carousel: true)
        
        # 4. Create an Ad Set for a Campaign
        
        # - a. First, create your targeting
        targeting = FacebookAds::AdTargeting.new
        targeting.excluded_connections = [config.page_id]
        
        # - b. Create the ad set
        ad_set = campaign.create_ad_set(
            name: 'Test Ad Set',
            targeting: targeting,
            promoted_object: {
                page_id: config.page_id },
            optimization_goal: 'PAGE_LIKES',
            daily_budget: 25000, # in cents
            billing_event: 'PAGE_LIKES',
            status: 'PAUSED')
        
        # 5. Create the Ad (finally!)
        ad = ad_set.create_ad(
            name: 'Test Ad', creative_id: ad_creative.id, status: 'PAUSED')
        
        # Error:
        # ===
        # This account has been created too recently, or spends too little to be
        # eligible for CPA ad creation
    end
end

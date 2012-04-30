module NavelGazer
  class Twitter < LinkedAccount
    include LetMeIn::LinkedAccounts::Twitter
    
    DEV_URL = "https://dev.twitter.com/apps"
    API_URL = "https://api.twitter.com/1"

    EXCLUDE_SOURCES = ['foursquare', 'banters', 'instagram']

    # Import tweets. Convert options to request parameters. 
    # See https://dev.twitter.com/docs/api/1/get/statuses/user_timeline for options
    def import options={}
      puts "Twitter.import"
      return nil if token.nil? || secret.nil?
      puts "Twitter.import continue"
      options ||= {}
      if !options.has_key?(:since_id) && !options.has_key?(:before_id)
        last_post = posts.last
        options[:since_id] = last_post.source_id if last_post
        options[:count] = 20
      end
      options[:max_id] = options.delete(:before_id) if options.has_key?(:before_id)
      puts "options: #{options.inspect}"
      data = JSON.parse(access_token.get("/1/statuses/user_timeline.json?#{options.to_param}").body)
      puts "data: #{data.inspect}"
      if data.is_a?(Hash) && data['error']
        update_attributes(:secret => nil, :token => nil)
        logger.error "ERROR IMPORTING FROM TWITTER: #{data.inspect}"
        return nil
      end
      new_items = parse_data(data)
      puts "new items: #{new_items.inspect}"
      Media.fetch_for_posts(new_items)
      new_items.count
    end


    # Example retweet format: https://api.twitter.com/statuses/show/171089518739464193.json
    def parse_data data
      response = []
      data.each do |item|
        if item['source'] =~ /(#{EXCLUDE_SOURCES.join('|')})/i
          next 
        end
        retweet = !(item['retweeted_status'].nil?)
        content = retweet ? item['retweeted_status']['text'] : item['text']
        next if content[0] == '@'
        op_name = retweet ? item['retweeted_status']['user']['screen_name'] : item['user']['screen_name']
        post = posts.find_or_create_by_source_id(item['id_str'])
        post.update_attributes!(
          :permalink => "http://twitter.com/#{item['user']['screen_name']}/status/#{item['id_str']}",
          :activity_type => retweet ? 'retweet' : 'tweet',
          :content => content,
          :author_name => op_name,
          :author_url => "http://twitter.com/#{op_name}",
          :author_image => retweet ? item['retweeted_status']['user']['profile_image_url'] : item['user']['profile_image_url'],
          :source_created_at => item['created_at'])
        response << post
      end
      response
    end


    def access_token
      @access_token ||= OAuth::AccessToken.new(consumer, token, secret)
    end

    def consumer
      @consumer ||= OAuth::Consumer.new(Twitter.key, Twitter.secret, :site => "https://api.twitter.com")
    end

  end
end

module NavelGazer
  class Tumblr < LinkedAccount
    include LetMeIn::LinkedAccounts::TumblrAccount
      
    DEV_URL = "https://www.tumblr.com/docs/en/api/v2"
    API_URL = "http://api.tumblr.com/v2"
    MIN_IMAGE_WIDTH = 250

    def import options={}
      return nil if token.nil?
      options ||= {}
      #if !options.has_key?(:since_id) && !options.has_key?(:before_id)
      #  last_post = posts.last
      #  options[:offset] = last_post.source_id if last_post
      #end
      options[:limit] = options.delete(:count) if options[:count]
      options[:limit] = 20 if options[:limit] && options[:limit] > 20
      #options[:offset] = options[:since_id] if options.has_key? :since_id
      response = RestClient.get("#{API_URL}/blog/#{app_user_id}.tumblr.com/posts", 
                                :params => options.merge({:api_key => NavelGazer::Tumblr.key}))
      posts = parse_data(JSON.parse(response))

      posts.count
    end

    def parse_data data
      response = []
      data['response']['posts'].each do |item|
        post = posts.find_or_create_by_source_id(:source_id => item['id'].to_s)
        post.update_attributes!(
          :permalink => item['post_url'],
          :activity_type => item['type'] == 'photo' ? 'photo' : 'text',
          :author_name => app_username,
          :author_image => image_url,
          :author_url => url,
          :source_created_at => DateTime.strptime(item['timestamp'].to_s, '%s'),
          :content => get_content(item) #TODO clean
        )

        if item['photos'] 
          sizes = item['photos'][0]['alt_sizes'].sort! { |a,b| b['width'].to_i <=> a['width'].to_i } 
          sizes = sizes.select { |a| a['width'].to_i >= MIN_IMAGE_WIDTH }
            
          media = Media.find_or_create_by_post_id(:post_id => post.id)
          media.update_attributes(
            :post_id => post.id,
            :embed_type => 'photo',
            :author_name => app_username,
            :author_url => url,
            :provider_name => 'Tumblr',
            :provider_url => 'http://tumblr.com/',
            :thumbnail_url => sizes.last['url'],
            :thumbnail_width => sizes.last['width'],
            :thumbnail_height => sizes.last['height'],
            :description => item['photos'][0]['caption'],
            :url => item['photos'][0]['original_size']['url'],
            :width => item['photos'][0]['original_size']['width'],
            :height => item['photos'][0]['original_size']['height'],
            :html => sizes.last['url'])
        end

        response << post
      end
      response
    end

    def get_content item
      case item['type'] 
        when 'audio'
          item['player']
        when 'chat'
          item['body']
        when 'photo'
          item['caption']
        when 'quote'
          "#{item['text']} #{item['source']}"
        when 'text'
          item['body']   
        when 'video'
          item['player'][0]['embed_code']
        else 
          ""
      end  
    
    end
  end
end

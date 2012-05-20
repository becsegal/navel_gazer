module NavelGazer
  class Tumblr < LinkedAccount
    include LetMeIn::LinkedAccounts::TumblrAccount
      
    DEV_URL = "https://www.tumblr.com/docs/en/api/v2"
    API_URL = "http://api.tumblr.com/v2"
    PROVIDER_NAME = "Tumblr"
    PROVIDER_URL = "http://www.tumblr.com"
    MIN_IMAGE_WIDTH = 250
    VIDEO_WIDTH = 400;

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

    # parse reaponse data and save posts 
    def parse_data data
      response = []
      data['response']['posts'].each do |item|
        post = posts.find_or_create_by_source_id(:source_id => item['id'].to_s)
        post.update_attributes!(
          :permalink => item['post_url'],
          :activity_type => item['type'],
          :author_name => app_username,
          :author_image => image_url,
          :author_url => url,
          :source_created_at => DateTime.strptime(item['timestamp'].to_s, '%s'),
          :content => get_content(item)
        )

        create_media(item, post) 

        response << post
      end
      response
    end

    # get main post content based on content type 
    # might need to format 
    def get_content item
      case item['type'] 
        when 'chat'
          item['body']
        when 'link'
          url = item['url']
          title = item['title']
          "<a href='#{url}' target='_blank'>#{title}</a>"
        when 'photo'
          item['caption']
        when 'quote'
          "#{item['text']} #{item['source']}"
        when 'text'
          item['body']   
        else 
          nil 
      end  
    end

    # create media records for a post
    # supported content types are 'auto', 'photo' and 'video'
    def create_media(item, post)

      case item['type'] 
        when 'audio'
           media = Media.find_or_create_by_post_id(:post_id => post.id)
           media.update_attributes(
            :post_id => post.id,
            :embed_type => item['type'],
            :author_name => app_username,
            :author_url => url,
            :provider_name => PROVIDER_NAME,
            :provider_url => PROVIDER_URL,
            :html => item['player'])
        when 'photo'
          if item['photos'] 
            sizes = item['photos'][0]['alt_sizes'].sort! { |a,b| a['width'].to_i <=> b['width'].to_i } 
            sizes = sizes.select { |a| a['width'].to_i > MIN_IMAGE_WIDTH }
               
            media = Media.find_or_create_by_post_id(:post_id => post.id)
            media.update_attributes(
              :post_id => post.id,
              :embed_type => item['type'],
              :author_name => app_username,
              :author_url => url,
              :provider_name => PROVIDER_NAME,
              :provider_url => PROVIDER_URL,
              :thumbnail_url => sizes.first['url'],
              :thumbnail_width => sizes.first['width'],
              :thumbnail_height => sizes.first['height'],
              :description => item['photos'][0]['caption'],
              :url => item['photos'][0]['original_size']['url'],
              :width => item['photos'][0]['original_size']['width'],
              :height => item['photos'][0]['original_size']['height'],
              :html => sizes.first['url'])
          end
        when 'video'
          player = item['player'].select { |a| a['width'].to_i == VIDEO_WIDTH }
          player = item['player'][0] if player.nil?

          media = Media.find_or_create_by_post_id(:post_id => post.id)
          media.update_attributes(
            :post_id => post.id,
            :embed_type => item['type'],
            :author_name => app_username,
            :author_url => url,
            :provider_name => PROVIDER_NAME,
            :provider_url => PROVIDER_URL,
            :html => player.first['embed_code'])
      end  
    end

  end
end

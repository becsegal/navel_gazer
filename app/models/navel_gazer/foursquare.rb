module NavelGazer
  class Foursquare < LinkedAccount
    include LetMeIn::LinkedAccounts::FoursquareAccount
      
    DEV_URL = "https://developer.foursquare.com/index"
    API_URL = "https://api.foursquare.com/v2"

    def import options={}
      return nil if token.nil?
      options ||= {}
      if !options.has_key?(:since_id) && !options.has_key?(:before_id)
        last_post = posts.last
        options[:afterTimesetamp] = last_post.source_id if last_post
      end
      options[:limit] = options.delete(:count) if options[:count]
      options[:limit] = 20 if options[:limit] && options[:limit] > 20
      options[:afterTimestamp] = options[:since_id] if options.has_key? :since_id
      options[:beforeTimestamp] = options[:before_id] if options.has_key? :before_id
      response = RestClient.get("#{API_URL}/users/#{app_user_id}/checkins", 
                                :params => options.merge({:oauth_token => token}))
      posts = parse_data(JSON.parse(response))


      posts.count
    end

    def parse_data data
      response = []
      data['response']['checkins']['items'].each do |item|
        post = posts.find_or_create_by_source_id(:source_id => item['id'].to_s)
        post.update_attributes!(
          :permalink => "#{url}/checkin/#{item['id']}",
          :activity_type => item[:type],
          :author_name => app_username,
          :author_image => image_url,
          :author_url => url,
          :source_created_at => DateTime.strptime(item['createdAt'].to_s,'%s'),
          :content => "#{item['shout']} @ #{item['venue']['name']}".strip
        )

        photo = item['photos']['items'][0]
        if photo
          images = photo['sizes']['items'].sort! { |a,b| b['width'].to_i <=> a['width'].to_i }  
          images = images.select { |a| a['width'].to_i >= 100 }
        end
            
        media = Media.find_or_create_by_post_id(:post_id => post.id)
        media.update_attributes(
          :post_id => post.id,
          :embed_type => images ? 'photo' : 'text',
          :author_name => app_username,
          :author_url => url,
          :provider_name => 'Foursquare',
          :provider_url => 'http://foursquare.com/',
          :thumbnail_url => images ? images.last['url'] : nil ,
          :thumbnail_width => images ? images.last['width'] : nil,
          :thumbnail_height => images ? images.last['height'] : nil,
          :description => "#{item['shout']} @ #{item['venue']['name']}".strip,
          :url => images ? images.first['url'] : nil,
          :width => images ? images.first['width'] : nil,
          :height => images ? images.first['height'] : nil,
          :html => images ? images.first['url'] : nil)

        response << post
      end
      response
    end
  end
end

module NavelGazer
  class Instagram < LinkedAccount
    include LetMeIn::LinkedAccounts::Instagram

    DEV_URL = "http://instagr.am/developer/"
    API_URL = "https://api.instagram.com"

    def import options={}
      return nil if token.nil?
      options ||= {}
      
      if !options.has_key?(:since_id) && !options.has_key?(:before_id)
        last_post = posts.last
        options[:min_id] = last_post.source_id if last_post
        options[:count] = 20
      end
      options[:max_id] = options.delete(:before_id) if options.has_key?(:before_id)
  
      response = RestClient.get("#{API_URL}/v1/users/#{app_user_id}/media/recent", 
                                :params => options.merge({:access_token => token}))
      posts = parse_data(JSON.parse(response))
      posts.count
    end

    # http://instagr.am/developer/endpoints/users/#get_users_media_recent
    def parse_data data
      response = []
      data['data'].each do |item|
        post = posts.find_or_create_by_source_id(item['id'])
        post.update_attributes!(
          :source_id => item['id'],
          :permalink => item['link'],
          :activity_type => 'post',
          :content => item['caption'] ? item['caption']['text'] : '',
          :author_name => item['user']['username'],
          :author_image => item['user']['profile_picture'],
          :source_created_at => DateTime.strptime(item['created_time'],'%s')
        )
        media = Media.find_or_create_by_post_id(:post_id => post.id)
        media.update_attributes(
          :post_id => post.id,
          :embed_type => 'photo',
          :author_name => item['user']['username'],
          :author_url => item['user']['website'],
          :provider_name => 'Instagram',
          :provider_url => 'http://instagram.com/',
          :thumbnail_url => item['images']['thumbnail']['url'],
          :thumbnail_width => item['images']['thumbnail']['width'],
          :thumbnail_height => item['images']['thumbnail']['height'],
          :description => item['caption'] ? item['caption']['text'] : '',
          :url => item['link'],
          :width => item['images']['standard_resolution']['width'],
          :height => item['images']['standard_resolution']['height'],
          :html => item['images']['standard_resolution']['url'])
        response << post
      end
      response
    end
  end
end
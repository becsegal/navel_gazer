module NavelGazer
  class Banters < LinkedAccount
    include LetMeIn::LinkedAccounts::BantersAccount
      
    DEV_URL = "https://banters.com/api/doc"
    API_URL = "https://banters.com/"

    def import options={}
      return nil if token.nil?
      options ||= {}
      if !options.has_key?(:since_id) && !options.has_key?(:before_id)
        last_post = posts.last
        options[:after_id] = last_post.source_id if last_post
      end
      options[:limit] = options.delete(:count) if options[:count]
      options[:limit] = 20 if options[:limit] && options[:limit] > 20
      response = RestClient.get("#{API_URL}/api/v2/#{app_username}/posts", 
                                :params => options.merge({:oauth_token => token}))
      posts = parse_data(JSON.parse(response))
      Media.fetch_for_posts(posts)
      posts.count
    end

    def parse_data data
      response = []
      data['collection'].each do |item|
        post = posts.find_or_create_by_source_id(:source_id => item['id'].to_s)
        post.update_attributes!(
          :permalink => "https://banters.com/p/#{item['id']}",
          :activity_type => 'post',
          :author_name => item['user']['username'],
          :author_image => item['user']['profile_photo']['medium'],
          :author_url => "https://banters.com/#{item['user']['username']}",
          :source_created_at => DateTime.strptime(item['created_at'],'%s'))
        response << post
      end
      response
    end
  end
end

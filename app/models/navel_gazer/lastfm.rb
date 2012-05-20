module NavelGazer
  class Lastfm < LinkedAccount
    include LetMeIn::LinkedAccounts::LastfmAccount
      
    DEV_URL = "http://www.last.fm/api"
    API_URL = "http://ws.audioscrobbler.com/2.0"

    def import options={}
      return nil if token.nil?

      options ||= {}
      if !options.has_key?(:since_id) && !options.has_key?(:before_id)
        last_post = posts.last
        options[:from] = last_post.source_id if last_post
      end
      options[:from] = options[:since_id] if options.has_key? :since_id
      options[:to] = options[:before_id] if options.has_key? :before_id
      
      options[:user] = app_user_id
      options[:method] = "user.getweeklyartistchart"
      response = RestClient.get("#{API_URL}", :params => options.merge({:api_key => NavelGazer::Lastfm.key})) 
      post = parse_data(Hash.from_xml(response))
    end

    def parse_data data
      response = []

      # create post content
      post_content = ''
      for artist in data['lfm']['weeklyartistchart']['artist'][0...4] do
        artist_url = artist['url']
        artist_name = artist['name']
        post_content += "<li><a href=\"#{artist_url}\" target=\"_blank\">#{artist_name}</a></li>"
      end 
      from_date_string = DateTime.strptime(data['lfm']['weeklyartistchart']['from'].to_s, '%s').strftime("%h %e")
      to_date_string   = DateTime.strptime(data['lfm']['weeklyartistchart']['to'].to_s, '%s').strftime("%h %e")
      post_content = "<ol>Top Artists (#{from_date_string} - #{to_date_string}):<br/> #{post_content}</ol>"

      # save post in db
      post = posts.find_or_create_by_source_id(:source_id => data['lfm']['weeklyartistchart']['from'].to_s)
      post.update_attributes!(
          :permalink => "http://www.last.fm/user/#{app_user_id}/charts?charttype=weekly&subtype=artist" +
                        "&range=#{data['lfm']['weeklyartistchart']['from']}-#{data['lfm']['weeklyartistchart']['to']}",
          :activity_type => 'text',
          :author_name => app_username,
          :author_image => nil,
          :author_url => "http://last.fm/user/#{app_user_id}",
          :source_created_at => DateTime.strptime(data['lfm']['weeklyartistchart']['to'].to_s, '%s'),
          :content => post_content
      )

      post 
    end

  end
end

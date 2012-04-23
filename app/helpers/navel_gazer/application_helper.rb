module NavelGazer
  module ApplicationHelper
    
    def title
      "Navel Gazer"
    end
    
    def about
      "<img src='#{asset_path 'navel_gazer/profile.png'}' />
      <h1>Your Name</h1>
      <p class='short_desc'>A short description about yourself.</p>
      <div class='clear'></div>
      <div class='long_desc'>
        <p>A longer description about yourself. Go nuts. Override a helper named 'about'</p>
      </div>".html_safe
    end
    
  end
end

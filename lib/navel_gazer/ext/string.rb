class String
  
  # url regex from ActionView::Helpers::TextHelper
  AUTO_LINK_RE = %r{\b(http[s]?:\/\/)?([^\s:\/]*\.\w{2,6}([\/\?]+[^\s]*)*)\b}
  
  def links 
    links = []
    scan(AUTO_LINK_RE) { |a,b| links << (a ? "#{a}#{b}" : "http://#{b}") }
    links
  end
  
end
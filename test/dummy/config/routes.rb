Rails.application.routes.draw do
  scope :module => "navel_gazer" do
    NavelGazer::Routes.draw(self)
  end  
  scope :module => "let_me_in" do
    LetMeIn::Routes.draw(self)
  end
end

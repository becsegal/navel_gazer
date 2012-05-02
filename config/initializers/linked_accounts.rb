begin
  if user = NavelGazer::User.first
    LetMeIn::Engine.config.linked_account_class_names = 
      ['NavelGazer::Banters', 'NavelGazer::Instagram', 'NavelGazer::Twitter']    
    LetMeIn::Engine.config.linked_account_class_names.each do |class_name|
      user.linked_accounts.find_or_create_by_type(:type => class_name)
    end
  end
rescue
end
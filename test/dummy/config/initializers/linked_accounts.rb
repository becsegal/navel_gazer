if user = NavelGazer::User.first
  user.linked_accounts.find_or_create_by_type(:type => 'Banters')
  user.linked_accounts.find_or_create_by_type(:type => 'Instagram')
  user.linked_accounts.find_or_create_by_type(:type => 'Twitter')
end
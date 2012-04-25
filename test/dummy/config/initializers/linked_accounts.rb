
if user = LetMeIn::User.first
  user.linked_accounts.find_or_create_by_type(:type => 'LetMeIn::Banters')
  user.linked_accounts.find_or_create_by_type(:type => 'LetMeIn::Instagram')
  user.linked_accounts.find_or_create_by_type(:type => 'LetMeIn::Twitter')
end
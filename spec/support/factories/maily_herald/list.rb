FactoryGirl.define do
  factory :list, class: "MailyHerald::List" do
    name "new_list"
    title "New list"
    context_name :all_users
  end
end

FactoryGirl.define do
  factory :weekly_summary, class: "MailyHerald::PeriodicalMailing" do
    type "MailyHerald::PeriodicalMailing"
    conditions "user.weekly_notifications == true"
    start_at "user.created_at"
    mailer_name "generic"
    name "weekly_summary"
    title "Test periodical mailing"
    subject "Weekly summary"
    template "User name: {{user.name}}."
    list :generic_list
    state "enabled"
    override_subscription false
    period 604800
  end
end

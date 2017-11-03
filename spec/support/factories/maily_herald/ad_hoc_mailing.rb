FactoryGirl.define do
  factory :ad_hoc_mailing, class: "MailyHerald::AdHocMailing" do
    type "MailyHerald::AdHocMailing"
    mailer_name "AdHocMailer"
    name "ad_hoc_mail"
    title "Ad hoc mailing"
    subject "Hello!"
    template_plain "hello"
    template_html nil
    state "enabled"
    list :generic_list
  end
end

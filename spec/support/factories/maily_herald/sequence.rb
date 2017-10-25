FactoryGirl.define do
  factory :clean_sequence, class: "MailyHerald::Sequence" do
    type "MailyHerald::Sequence"
    mailer_name "generic"
    name "clean_sequence"
    title "Clean Sequence"
    list :generic_list
    start_at "user.created_at"
    state "enabled"
  end

  factory :newsletters, class: "MailyHerald::Sequence" do
    type "MailyHerald::Sequence"
    mailer_name "generic"
    name "newsletters"
    title "Newsletters"
    list :generic_list
    start_at "user.created_at"
    state "enabled"

    after(:create) do |sequence|
      create :initial_mail, sequence: sequence
      create :second_mail, sequence: sequence
      create :third_mail, sequence: sequence
    end
  end
end

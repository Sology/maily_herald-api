require 'rails_helper'

describe Mail::MessageSerializer do

  describe "serializing Mail::MessageSerializer object" do
    let!(:mailing)  { create :generic_one_time_mailing }
    let!(:entity)   { create :user }
    let(:mail)      { mailing.build_mail entity }

    before do
      mailing.list.subscribe! entity
      mailing.reload
    end

    it { expect(MailyHerald::OneTimeMailing.count).to eq(2) }
    it { expect(mailing.list.active_subscription_count).to eq(1) }
    it "should return serialized object" do
        expect(described_class.new(mail).as_json).to eq({
          messageId: nil,
          date: nil,
          headers: [
              {:name=>"From",         :value=>"foo@bar.com"},
              {:name=>"To",           :value=>"#{entity.email}"},
              {:name=>"Subject",      :value=>"#{mailing.subject}"},
              {:name=>"Mime-Version", :value=>"1.0"},
              {:name=>"Content-Type", :value=>"text/plain"}
            ],
          body: {
              charset:    "US-ASCII",
              encoding:   "7bit",
              rawSource:  "User name: #{entity.name}."
            }
          })
    end
  end

end

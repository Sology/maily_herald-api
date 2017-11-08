require 'rails_helper'

describe Mail::MessageSerializer do

  describe "serializing Mail::MessageSerializer object" do
    before do
      mailing.list.subscribe! entity
      mailing.reload
    end

    context "with plain template with custom mailer" do
      let!(:mailing)  { create :ad_hoc_mailing }
      let!(:entity)   { create :user }
      let(:mail)      { mailing.build_mail entity }

      it { expect(MailyHerald::AdHocMailing.count).to eq(1) }
      it { expect(mailing.list.active_subscription_count).to eq(1) }
      it "should return serialized object" do
        expect(described_class.new(mail).as_json).to eq({
          messageId: nil,
          date: nil,
          headers: [
            {name: "From",         value: "no-reply@mailyherald.org"},
            {name: "To",           value: entity.email},
            {name: "Subject",      value: "Test"},
            {name: "Mime-Version", value: "1.0"},
            {name: "Content-Type", value: "text/plain"}
          ],
          body: {
            charset: "US-ASCII",
            encoding: "7bit",
            rawSource: "Hello\n\n"
          }
        })
      end
    end

    context "with both templates with generic mailer" do
      let!(:mailing)  { create :generic_one_time_mailing, template_html: "<h1>Hello {{ user.name }}</h1>" }
      let!(:entity)   { create :user }
      let(:mail)      { mailing.build_mail entity }

      it { expect(MailyHerald::OneTimeMailing.count).to eq(2) }
      it { expect(mailing.list.active_subscription_count).to eq(1) }
      it "should return serialized object" do
          expect(described_class.new(mail).as_json).to eq({
            messageId: nil,
            date: nil,
            headers: [
              {name: "From",         value: "foo@bar.com"},
              {name: "To",           value: entity.email},
              {name: "Subject",      value: "Test mailing"},
              {name: "Mime-Version", value: "1.0"}
            ],
            parts: [
              {
                headers: [{name: "Content-Type", value: "text/plain"}],
                body:
                  {
                    charset: "US-ASCII",
                    encoding: "7bit",
                    rawSource: "User name: #{entity.name}."
                  }
              },
              {
                headers: [{name: "Content-Type", value: "text/html"}],
                body:
                  {
                    charset: "US-ASCII",
                    encoding: "7bit",
                    rawSource: "<h1>Hello #{entity.name}</h1>"
                  }
              }
            ],
          }
        )
      end
    end
  end

end

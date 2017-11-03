require 'rails_helper'

describe MailyHerald::OneTimeMailingSerializer do

  describe "serializing MailyHerald::OneTimeMailing object" do
    let!(:one_time_mailing) { create :generic_one_time_mailing }

    context "setup" do
      it { expect(MailyHerald::OneTimeMailing.count).to eq(2) }
    end

    it "should return serialized object" do
      expect(described_class.new(one_time_mailing).as_json).to eq({
        id:         one_time_mailing.id,
        listId:     one_time_mailing.list.id,
        kind:       one_time_mailing.kind,
        conditions: one_time_mailing.conditions,
        from:       one_time_mailing.from,
        mailerName: one_time_mailing.mailer_name,
        name:       one_time_mailing.name,
        state:      one_time_mailing.state,
        subject:    one_time_mailing.subject,
        template:   {
                      html:  one_time_mailing.template_plain,
                      plain: one_time_mailing.template_plain
                    },
        title:      one_time_mailing.title,
        startAt:    one_time_mailing.start_at.as_json,
        locked:     false
      })
    end
  end

end

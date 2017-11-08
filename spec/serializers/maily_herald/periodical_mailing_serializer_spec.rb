require 'rails_helper'

describe MailyHerald::PeriodicalMailingSerializer do

  describe "serializing MailyHerald::PeriodicalMailing object" do
    let!(:periodical_mailing) { create :weekly_summary }

    context "setup" do
      it { expect(MailyHerald::PeriodicalMailing.count).to eq(1) }
    end

    it "should return serialized object" do
      expect(described_class.new(periodical_mailing).as_json).to eq({
        id:            periodical_mailing.id,
        listId:        periodical_mailing.list.id,
        kind:          periodical_mailing.kind,
        conditions:    periodical_mailing.conditions,
        from:          periodical_mailing.from,
        mailerName:    periodical_mailing.mailer_name,
        name:          periodical_mailing.name,
        state:         periodical_mailing.state,
        subject:       periodical_mailing.subject,
        template:      {
                         html:  periodical_mailing.template_plain,
                         plain: periodical_mailing.template_plain
                       },
        title:         periodical_mailing.title,
        track:         true,
        startAt:       periodical_mailing.start_at.as_json,
        period:        periodical_mailing.period, 
        locked:        false
      })
    end
  end

end

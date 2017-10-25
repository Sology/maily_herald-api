require 'rails_helper'

describe MailyHerald::SequenceSerializer do

  describe "serializing MailyHerald::Sequence object" do
    subject { described_class.new(sequence).as_json }

    context "without sequence mailings" do
      let!(:sequence) { create :clean_sequence }

      context "setup" do
        it { expect(MailyHerald::Sequence.count).to eq(1) }
        it { expect(MailyHerald::SequenceMailing.count).to eq(0) }
        it { expect(sequence.mailings.count).to eq(0) }
      end

      it "should return serialized object" do
        expect(subject).to eq({
          id:                 sequence.id,
          listId:             sequence.list.id,
          name:               sequence.name,
          state:              sequence.state,
          title:              sequence.title,
          startAt:            sequence.start_at.as_json,
          locked:             false,
          sequenceMailings:   []
        })
      end
    end

    context "with sequence mailings" do
      let!(:sequence) { create :newsletters }
      let!(:mailing1) { sequence.mailings.where(name: "initial_mail").first }
      let!(:mailing2) { sequence.mailings.where(name: "second_mail").first }
      let!(:mailing3) { sequence.mailings.where(name: "third_mail").first }

      context "setup" do
        it { expect(MailyHerald::Sequence.count).to eq(1) }
        it { expect(MailyHerald::SequenceMailing.count).to eq(3) }
        it { expect(sequence.mailings.count).to eq(3) }
        it { expect(mailing1).not_to be_nil }
        it { expect(mailing2).not_to be_nil }
        it { expect(mailing3).not_to be_nil }
      end

      it "should return serialized object" do
        expect(subject).to eq({
          id:                 sequence.id,
          listId:             sequence.list.id,
          name:               sequence.name,
          state:              sequence.state,
          title:              sequence.title,
          startAt:            sequence.start_at.as_json,
          locked:             false,
          sequenceMailings:   [
                                {
                                  id:                   mailing1.id,
                                  sequenceId:           sequence.id,
                                  name:                 mailing1.name,
                                  title:                mailing1.title,
                                  subject:              mailing1.subject,
                                  template:             mailing1.template,
                                  conditions:           mailing1.conditions,
                                  from:                 mailing1.from,
                                  state:                mailing1.state,
                                  mailerName:           mailing1.mailer_name,
                                  locked:               false,
                                  absoluteDelayInDays:  mailing1.absolute_delay_in_days
                                },
                                {
                                  id:                   mailing2.id,
                                  sequenceId:           sequence.id,
                                  name:                 mailing2.name,
                                  title:                mailing2.title,
                                  subject:              mailing2.subject,
                                  template:             mailing2.template,
                                  conditions:           mailing2.conditions,
                                  from:                 mailing2.from,
                                  state:                mailing2.state,
                                  mailerName:           mailing2.mailer_name,
                                  locked:               false,
                                  absoluteDelayInDays:  mailing2.absolute_delay_in_days
                                },
                                {
                                  id:                   mailing3.id,
                                  sequenceId:           sequence.id,
                                  name:                 mailing3.name,
                                  title:                mailing3.title,
                                  subject:              mailing3.subject,
                                  template:             mailing3.template,
                                  conditions:           mailing3.conditions,
                                  from:                 mailing3.from,
                                  state:                mailing3.state,
                                  mailerName:           mailing3.mailer_name,
                                  locked:               false,
                                  absoluteDelayInDays:  mailing3.absolute_delay_in_days
                                }
                              ]
        })
      end
    end
  end

end

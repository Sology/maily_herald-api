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
                                  kind:                 mailing1.kind,
                                  name:                 mailing1.name,
                                  title:                mailing1.title,
                                  subject:              mailing1.subject,
                                  template:             {
                                                          html:  mailing1.template_plain,
                                                          plain: mailing1.template_plain
                                                        },
                                  conditions:           mailing1.conditions,
                                  from:                 mailing1.from,
                                  state:                mailing1.state,
                                  mailerName:           mailing1.mailer_name,
                                  locked:               false,
                                  track:                true,
                                  absoluteDelay:        mailing1.absolute_delay
                                },
                                {
                                  id:                   mailing2.id,
                                  sequenceId:           sequence.id,
                                  kind:                 mailing2.kind,
                                  name:                 mailing2.name,
                                  title:                mailing2.title,
                                  subject:              mailing2.subject,
                                  template:             {
                                                          html:  mailing2.template_plain,
                                                          plain: mailing2.template_plain
                                                        },
                                  conditions:           mailing2.conditions,
                                  from:                 mailing2.from,
                                  state:                mailing2.state,
                                  mailerName:           mailing2.mailer_name,
                                  locked:               false,
                                  track:                true,
                                  absoluteDelay:        mailing2.absolute_delay
                                },
                                {
                                  id:                   mailing3.id,
                                  sequenceId:           sequence.id,
                                  kind:                 mailing3.kind,
                                  name:                 mailing3.name,
                                  title:                mailing3.title,
                                  subject:              mailing3.subject,
                                  template:             {
                                                          html:  mailing3.template_plain,
                                                          plain: mailing3.template_plain
                                                        },
                                  conditions:           mailing3.conditions,
                                  from:                 mailing3.from,
                                  state:                mailing3.state,
                                  mailerName:           mailing3.mailer_name,
                                  locked:               false,
                                  track:                true,
                                  absoluteDelay:        mailing3.absolute_delay
                                }
                              ]
        })
      end
    end
  end

end

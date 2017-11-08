require 'rails_helper'

describe MailyHerald::SequenceMailingSerializer do

  describe "serializing MailyHerald::SequenceMailing object" do
    let!(:sequence)         { create :newsletters }
    let!(:sequence_mailing) { sequence.mailings.first }

    context "setup" do
      it { expect(MailyHerald::SequenceMailing.count).to eq(3) }
      it { expect(sequence_mailing).not_to be_nil }
    end

    it "should return serialized object" do
      expect(described_class.new(sequence_mailing).as_json).to eq({
        id:                   sequence_mailing.id,
        sequenceId:           sequence_mailing.sequence_id,
        kind:                 sequence_mailing.kind,
        conditions:           sequence_mailing.conditions,
        from:                 sequence_mailing.from,
        mailerName:           sequence_mailing.mailer_name,
        name:                 sequence_mailing.name,
        state:                sequence_mailing.state,
        subject:              sequence_mailing.subject,
        template:             {
                                html:  sequence_mailing.template_plain,
                                plain: sequence_mailing.template_plain
                              },
        title:                sequence_mailing.title,
        track:                true,
        locked:               false,
        absoluteDelay:        sequence_mailing.absolute_delay
      })
    end
  end

end

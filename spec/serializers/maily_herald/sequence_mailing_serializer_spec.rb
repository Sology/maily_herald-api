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
        conditions:           sequence_mailing.conditions,
        from:                 sequence_mailing.from,
        mailerName:           sequence_mailing.mailer_name,
        name:                 sequence_mailing.name,
        state:                sequence_mailing.state,
        subject:              sequence_mailing.subject,
        template:             sequence_mailing.template,
        title:                sequence_mailing.title,
        locked:               false,
        absoluteDelay:        sequence_mailing.absolute_delay
      })
    end
  end

end

require 'rails_helper'

describe MailyHerald::LogSerializer do

  describe "serializing MailyHerald::Log object" do
    let!(:mailing)  { create :ad_hoc_mailing }
    let!(:list)     { mailing.list }
    let!(:entity)   { create :user }
    let(:log)       { MailyHerald::Log.last }

    before do
      list.subscribe! entity
      list.reload
      mailing.schedule_delivery_to entity
      mailing.run
      mailing.reload
    end

    subject { described_class.new(log).as_json }

    context "setup" do
      it { expect(MailyHerald::Log.count).to eq(2) }
      it { expect(log).to be_kind_of(MailyHerald::Log) }
    end

    context "returning serialized object" do
      it { expect(subject[:id]).to eq(log.id) }
      it { expect(subject[:mailingId]).to eq(mailing.id) }
      it { expect(subject[:entityId]).to eq(entity.id) }
      it { expect(subject[:entityEmail]).to eq(entity.email) }
      it { expect(subject[:entityType]).to eq(entity.class.to_s) }
      it { expect(subject[:status]).to eq(log.status) }
      it { expect(subject[:data]).to eq(log.data) }
      it { expect(subject[:processingAt]).not_to be_nil }
    end
  end

end

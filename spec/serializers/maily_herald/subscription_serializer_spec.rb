require 'rails_helper'

describe MailyHerald::SubscriptionSerializer do

  describe "serializing MailyHerald::ListSerializer object" do
    let!(:list)     { MailyHerald.list :generic_list }
    let!(:entity)   { create :user }

    before do
      list.subscribe! entity
      list.reload
    end

    context "setup" do
      it { expect(list.active_subscription_count).to eq(1) }
      it { expect(list.subscriptions.first).to be_kind_of(MailyHerald::Subscription) }
    end

    context "with active subscription" do
      it "should return serialized object" do
        expect(described_class.new(list.subscriptions.first).as_json).to eq({
          active: true,
          data: {},
          id: list.subscriptions.first.id,
          entityId: entity.id,
          listId: list.id,
          settings: {},
          unsubscribeUrl: list.subscriptions.first.token_url
        })
      end
    end

    context "with inactive subscription" do
      before do
        list.unsubscribe! entity
        list.reload
      end

      it "should return serialized object" do
        expect(described_class.new(list.subscriptions.first).as_json).to eq({
          active: false,
          data: {},
          id: list.subscriptions.first.id,
          entityId: entity.id,
          listId: list.id,
          settings: {},
          unsubscribeUrl: list.subscriptions.first.token_url
        })
      end
    end
  end

end

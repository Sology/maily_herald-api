require 'rails_helper'

describe MailyHerald::ListSerializer do

  describe "serializing MailyHerald::List object" do
    let!(:list) { MailyHerald.list :generic_list }

    context "with active subscription, opt-out and potential subscriber" do
      let!(:subscriber)           { create :user }
      let!(:optout)               { create :user }
      let!(:potentialsubscriber)  { create :user }

      before do
        list.subscribe! subscriber
        list.subscribe! optout
        list.unsubscribe! optout
        list.reload
      end

      context "setup" do
        it { expect(list.active_subscription_count).to eq(1) }
        it { expect(list.opt_outs_count).to eq(1) }
        it { expect(list.potential_subscribers_count).to eq(1) }
      end

      it "should return serialized object" do
        expect(described_class.new(list).as_json).to eq({
          id: list.id,
          contextName: "all_users",
          locked: true,
          name: "generic_list",
          optOutsCount: 1,
          potentialSubscribersCount: 1,
          subscribersCount: 1,
          title: "generic_list"
        })
      end
    end
  end

end

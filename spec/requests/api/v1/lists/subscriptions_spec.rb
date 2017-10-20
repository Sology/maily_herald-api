require "rails_helper"

describe "Subscriptions API" do

  describe "GET #index" do
    let!(:list)                   { create :list }
    let!(:subscriber)             { create :user }
    let!(:opt_out)                { create :user }
    let!(:potential_subscriber)   { create :user }

    before do
      list.subscribe! subscriber
      list.subscribe! opt_out
      list.unsubscribe! opt_out
      list.reload
    end

    context "setup" do
      it { expect(list.active_subscription_count).to eq(1) }
      it { expect(list.opt_outs_count).to eq(1) }
      it { expect(list.potential_subscribers_count).to eq(1) }
    end

    context "when not valid list ID" do
      before { send_request :get, "/maily_herald/api/v1/lists/0/subscriptions" }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
    end

    context "when valid list ID" do
      context "all subscriptions" do
        before { send_request :get, "/maily_herald/api/v1/lists/#{list.id}/subscriptions" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["subscriptions"]).to be_present }
        it { expect(response_json["subscriptions"].count).to eq(2) }
        it { expect(response_json["meta"]["pagination"]).to be_present }
        it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
        it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
      end

      context "active subscriptions" do
        before { send_request :get, "/maily_herald/api/v1/lists/#{list.id}/subscriptions", {kind: "active"} }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["subscriptions"]).to be_present }
        it { expect(response_json["subscriptions"].count).to eq(1) }
        it { expect(response_json["subscriptions"].first["entityId"]).to eq(subscriber.id) }
        it { expect(response_json["meta"]["pagination"]).to be_present }
        it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
        it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
      end
    end
  end

end

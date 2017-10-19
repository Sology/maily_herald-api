require "rails_helper"

describe "Lists API" do

  context "setup" do
    it { expect(MailyHerald.context(:all_users)).to be_kind_of(MailyHerald::Context) }
    it { expect(MailyHerald::List.count).to eq(2) } # From maily_herald's initializer
  end

  describe "GET #show" do
    let(:list) { MailyHerald.list :generic_list }

    context "with existing ID" do
      before { send_request :get, "/maily_herald/api/v1/lists/#{list.id}" }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["list"]["id"]).to eq(list.id) }
      it { expect(response_json["list"]["name"]).to eq(list.name) }
      it { expect(response_json["list"]["title"]).to eq(list.title) }
      it { expect(response_json["list"]["context_name"]).to eq(list.context_name) }
    end

    context "with non-existing ID" do
      before { send_request :get, "/maily_herald/api/v1/lists/0" }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
    end
  end

  describe "POST #create" do
    context "with correct params" do
      before { send_request :post, "/maily_herald/api/v1/lists", {list: {title: "New List", context_name: "all_users"}}.to_json }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(MailyHerald::List.count).to eq(3) }
      it { expect(response_json["list"]["id"]).to eq(MailyHerald::List.last.id) }
      it { expect(response_json["list"]["name"]).to eq("new_list") }
      it { expect(response_json["list"]["title"]).to eq("New List") }
      it { expect(response_json["list"]["context_name"]).to eq("all_users") }
      it { expect(response_json["list"]["locked"]).to eq(false) }
    end

    context "with incorrect params" do
      context "blank title" do
        before { send_request :post, "/maily_herald/api/v1/lists", {list: {title: "", context_name: "all_users"}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["name"]).to eq("blank") }
        it { expect(response_json["errors"]["title"]).to eq("blank") }
        it { expect(MailyHerald::List.count).to eq(2) }
      end

      context "missing title" do
        before { send_request :post, "/maily_herald/api/v1/lists", {list: {context_name: "all_users"}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["name"]).to eq("blank") }
        it { expect(response_json["errors"]["title"]).to eq("blank") }
        it { expect(MailyHerald::List.count).to eq(2) }
      end

      context "invalid context_name" do
        before { send_request :post, "/maily_herald/api/v1/lists", {list: {title: "New List", context_name: "wrongOne"}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["context"]).to eq("blank") }
        it { expect(MailyHerald::List.count).to eq(2) }
      end

      context "missing context_name" do
        before { send_request :post, "/maily_herald/api/v1/lists", {list: {title: "New List"}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["context"]).to eq("blank") }
        it { expect(MailyHerald::List.count).to eq(2) }
      end
    end
  end

  describe "PUT #update" do
    let!(:list) { create :list }

    context "when list is locked with correct params" do
      let!(:list) { MailyHerald.list :generic_list }

      before { send_request :put, "/maily_herald/api/v1/lists/#{list.id}", {list: {title: "Changed Title"}}.to_json }

      it { expect(response.status).to eq(422) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["errors"]["base"]).to eq("locked") }
    end

    context "when list is not locked" do
      context "with correct params" do
        before { send_request :put, "/maily_herald/api/v1/lists/#{list.id}", {list: {title: "Changed Title"}}.to_json }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["list"]["id"]).to eq(list.id) }
        it { expect(response_json["list"]["name"]).to eq("new_list") }
        it { expect(response_json["list"]["title"]).to eq("Changed Title") }
      end

      context "with incorrect params" do
        context "blank title" do
          before { send_request :put, "/maily_herald/api/v1/lists/#{list.id}", {list: {title: ""}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["title"]).to eq("blank") }
        end

        context "missing context_name" do
          before { send_request :put, "/maily_herald/api/v1/lists/#{list.id}", {list: {context_name: "wrongOne"}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["context"]).to eq("blank") }
        end
      end
    end
  end

  describe "POST #subscribe" do
    let!(:list)   { create :list }
    let!(:entity) { create :user }

    context "setup" do
      it { expect(User.count).to eq(1) }
      it { expect(list.subscriptions.count).to eq(0) }
    end

    context "with invalid params" do
      context "wrong list ID" do
        before { send_request :post, "/maily_herald/api/v1/lists/0/subscribe/#{entity.id}" }

        it { expect(response.status).to eq(404) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["error"]).to eq("notFound") }
        it { list.reload; expect(list.subscriptions.count).to eq(0) }
      end

      context "wrong entity ID" do
        before { send_request :post, "/maily_herald/api/v1/lists/#{list.id}/subscribe/0" }

        it { expect(response.status).to eq(404) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["error"]).to eq("notFound") }
        it { list.reload; expect(list.subscriptions.count).to eq(0) }
      end
    end

    context "with valid params" do
      context "when user did not have subscription for this list in the past" do
        before do
          send_request :post, "/maily_herald/api/v1/lists/#{list.id}/subscribe/#{entity.id}"
          list.reload
        end

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).to be_empty }
        it { expect(list.subscriptions.count).to eq(1) }
        it { expect(list.subscriptions.first).to be_kind_of(MailyHerald::Subscription) }
        it { expect(list.subscriptions.first.entity).to eq(entity) }
      end

      context "when user had subscription for this list in the past" do
        before do
          list.subscribe! entity
          expect(MailyHerald::Subscription.count).to eq(1)
          expect(list.subscriptions.first.entity).to eq(entity)
          expect(list.subscriptions.first.active).to be_truthy

          list.unsubscribe! entity
          expect(MailyHerald::Subscription.count).to eq(1)
          expect(list.subscriptions.first.active).to be_falsy

          send_request :post, "/maily_herald/api/v1/lists/#{list.id}/subscribe/#{entity.id}"
          list.reload
        end

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).to be_empty }
        it { expect(MailyHerald::Subscription.count).to eq(1) }
        it { expect(list.subscriptions.count).to eq(1) }
        it { expect(list.subscriptions.first).to be_kind_of(MailyHerald::Subscription) }
        it { expect(list.subscriptions.first.entity).to eq(entity) }
        it { expect(list.subscriptions.first.active).to be_truthy }
      end
    end
  end

  describe "POST #unsubscribe" do
    let!(:list)   { create :list }
    let!(:entity) { create :user }

    before { list.subscribe! entity }

    context "setup" do
      it { expect(User.count).to eq(1) }
      it { expect(MailyHerald::Subscription.count).to eq(1) }
      it { expect(list.subscriptions.count).to eq(1) }
      it { expect(list.subscriptions.first.entity).to eq(entity) }
      it { expect(list.subscriptions.first.active).to be_truthy }
    end

    context "with invalid params" do
      context "wrong list ID" do
        before { send_request :post, "/maily_herald/api/v1/lists/0/unsubscribe/#{entity.id}" }

        it { expect(response.status).to eq(404) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["error"]).to eq("notFound") }
        it { list.reload; expect(list.subscriptions.count).to eq(1) }
        it { expect(list.subscriptions.first.active).to be_truthy }
      end

      context "wrong entity ID" do
        before { send_request :post, "/maily_herald/api/v1/lists/#{list.id}/unsubscribe/0" }

        it { expect(response.status).to eq(404) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["error"]).to eq("notFound") }
        it { list.reload; expect(list.subscriptions.count).to eq(1) }
        it { expect(list.subscriptions.first.active).to be_truthy }
      end
    end

    context "with valid params" do
      context "when user's subscription is active" do
        before do
          send_request :post, "/maily_herald/api/v1/lists/#{list.id}/unsubscribe/#{entity.id}"
          list.reload
        end

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).to be_empty }
        it { expect(list.subscriptions.count).to eq(1) }
        it { expect(list.subscriptions.first.entity).to eq(entity) }
        it { expect(list.subscriptions.first.active).to be_falsy }
      end

      context "when user's subscription is not active" do
        before do
          list.unsubscribe! entity
          expect(MailyHerald::Subscription.count).to eq(1)
          expect(list.subscriptions.first.active).to be_falsy

          send_request :post, "/maily_herald/api/v1/lists/#{list.id}/unsubscribe/#{entity.id}"
          list.reload
        end

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).to be_empty }
        it { expect(list.subscriptions.count).to eq(1) }
        it { expect(list.subscriptions.first.entity).to eq(entity) }
        it { expect(list.subscriptions.first.active).to be_falsy }
      end
    end
  end

end

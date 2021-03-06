require "rails_helper"

describe "Lists API" do

  context "setup" do
    it { expect(MailyHerald.context(:all_users)).to be_kind_of(MailyHerald::Context) }
    it { expect(MailyHerald::List.count).to eq(2) } # From maily_herald's initializer
  end

  describe "GET #index" do
    context "without any params" do
      before { send_request :get, "/maily_herald/api/v1/lists/" }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["lists"].count).to eq(2) }
      it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
      it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
    end

    context "with defined per param" do
      before { send_request :get, "/maily_herald/api/v1/lists/", {per: 1} }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["lists"].count).to eq(1) }
      it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
      it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_truthy }
    end

    context "with defined per and page param" do
      before { send_request :get, "/maily_herald/api/v1/lists/", {per: 1, page: 2} }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["lists"].count).to eq(1) }
      it { expect(response_json["meta"]["pagination"]["page"]).to eq(2) }
      it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
    end

    context "with too high page param" do
      before { send_request :get, "/maily_herald/api/v1/lists/", {per: 1, page: 10} }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["lists"].count).to eq(0) }
      it { expect(response_json["meta"]["pagination"]["page"]).to eq(10) }
      it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
    end

    context "with defined query param" do
      before { send_request :get, "/maily_herald/api/v1/lists/", {query: query} }

      context "when query is 'gen'" do
        let(:query) { "gen" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["lists"].count).to eq(1) }
        it { expect(response_json["lists"].first["name"]).to eq("generic_list") }
        it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
        it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
      end

      context "when query is 'ked'" do
        let(:query) { "ked" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["lists"].count).to eq(1) }
        it { expect(response_json["lists"].first["name"]).to eq("locked_list") }
        it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
        it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
      end
    end
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
      it { expect(response_json["list"]["contextName"]).to eq(list.context_name) }
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
      it { expect(response_json["list"]["contextName"]).to eq("all_users") }
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

  describe "DELETE #destroy" do
    let!(:list) { create :list }

    it { expect(MailyHerald::List.count).to eq(3) }

    context "when list is locked with correct params" do
      let!(:locked_list) { MailyHerald.list :generic_list }

      before { send_request :delete, "/maily_herald/api/v1/lists/#{locked_list.id}" }

      it { expect(response.status).to eq(422) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["errors"]["base"]).to eq("locked") }
      it { expect(locked_list.reload).to eq(locked_list) }
      it { expect(MailyHerald::List.count).to eq(3) }
    end

    context "when list is not locked" do
      context "with valid list ID" do
        before { send_request :delete, "/maily_herald/api/v1/lists/#{list.id}" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).to be_empty }
        it { expect { list.reload }.to raise_exception(ActiveRecord::RecordNotFound) }
        it { expect(MailyHerald::List.count).to eq(2) }
      end

      context "with invalid list ID" do
        before { send_request :delete, "/maily_herald/api/v1/lists/0" }

        it { expect(response.status).to eq(404) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["error"]).to eq("notFound") }
        it { expect(list.reload).to eq(list) }
        it { expect(MailyHerald::List.count).to eq(3) }
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
        it { expect(response_json).not_to be_empty }

        it { expect(response_json["subscription"]["id"]).to eq(MailyHerald::Subscription.first.id) }
        it { expect(response_json["subscription"]["entityId"]).to eq(entity.id) }
        it { expect(response_json["subscription"]["listId"]).to eq(list.id) }
        it { expect(response_json["subscription"]["active"]).to be_truthy }
        it { expect(response_json["subscription"]["unsubscribeUrl"]).not_to be_nil }
        it { expect(response_json["subscription"]["settings"]).to be_kind_of(Hash) }
        it { expect(response_json["subscription"]["data"]).to be_kind_of(Hash) }

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
        it { expect(response_json).not_to be_empty }

        it { expect(response_json["subscription"]["id"]).to eq(MailyHerald::Subscription.first.id) }
        it { expect(response_json["subscription"]["entityId"]).to eq(entity.id) }
        it { expect(response_json["subscription"]["listId"]).to eq(list.id) }
        it { expect(response_json["subscription"]["active"]).to be_truthy }
        it { expect(response_json["subscription"]["unsubscribeUrl"]).not_to be_nil }
        it { expect(response_json["subscription"]["settings"]).to be_kind_of(Hash) }
        it { expect(response_json["subscription"]["data"]).to be_kind_of(Hash) }

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
        it { expect(response_json).not_to be_empty }

        it { expect(response_json["subscription"]["id"]).to eq(MailyHerald::Subscription.first.id) }
        it { expect(response_json["subscription"]["entityId"]).to eq(entity.id) }
        it { expect(response_json["subscription"]["listId"]).to eq(list.id) }
        it { expect(response_json["subscription"]["active"]).to be_falsy }
        it { expect(response_json["subscription"]["unsubscribeUrl"]).not_to be_nil }
        it { expect(response_json["subscription"]["settings"]).to be_kind_of(Hash) }
        it { expect(response_json["subscription"]["data"]).to be_kind_of(Hash) }

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
        it { expect(response_json).not_to be_empty }

        it { expect(response_json["subscription"]["id"]).to eq(MailyHerald::Subscription.first.id) }
        it { expect(response_json["subscription"]["entityId"]).to eq(entity.id) }
        it { expect(response_json["subscription"]["listId"]).to eq(list.id) }
        it { expect(response_json["subscription"]["active"]).to be_falsy }
        it { expect(response_json["subscription"]["unsubscribeUrl"]).not_to be_nil }
        it { expect(response_json["subscription"]["settings"]).to be_kind_of(Hash) }
        it { expect(response_json["subscription"]["data"]).to be_kind_of(Hash) }

        it { expect(list.subscriptions.count).to eq(1) }
        it { expect(list.subscriptions.first.entity).to eq(entity) }
        it { expect(list.subscriptions.first.active).to be_falsy }
      end
    end
  end

  describe "GET #subscribers" do
    let(:list)    { MailyHerald.list :generic_list }
    let(:entity)  { create :user }

    context "with incorrect MailyHerald::List ID" do
      before { send_request :get, "/maily_herald/api/v1/lists/0/subscribers" }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
    end

    context "with correct MailyHerald::List ID" do
      context "without subscribers" do
        before { send_request :get, "/maily_herald/api/v1/lists/#{list.id}/subscribers" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["subscribers"]).to be_kind_of(Array) }
        it { expect(response_json["subscribers"].count).to eq(0) }
      end

      context "with subscribers" do
        before do
          list.subscribe!(entity) && list.reload
          send_request :get, "/maily_herald/api/v1/lists/#{list.id}/subscribers"
        end

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["subscribers"]).to be_kind_of(Array) }
        it { expect(response_json["subscribers"].count).to eq(1) }
        it { expect(response_json["subscribers"].first["id"]).to eq(entity.id) }
        it { expect(response_json["subscribers"].first["email"]).to eq(entity.email) }
      end
    end
  end

  describe "GET #opt_outs" do
    let(:list)         { MailyHerald.list :generic_list }
    let!(:subscriber)  { create :user }
    let!(:opt_out)     { create :user }

    before do
      list.subscribe!(subscriber)
      list.subscribe!(opt_out)
      list.unsubscribe!(opt_out)
      list.reload
    end

    context "setup" do
      it { expect(list.subscribers).to include(subscriber) }
      it { expect(list.opt_outs).to include(opt_out) }
    end

    context "with incorrect MailyHerald::List ID" do
      before { send_request :get, "/maily_herald/api/v1/lists/0/opt_outs" }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
    end

    context "with correct MailyHerald::List ID" do
      before { send_request :get, "/maily_herald/api/v1/lists/#{list.id}/opt_outs" }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["optOuts"]).to be_kind_of(Array) }
      it { expect(response_json["optOuts"].count).to eq(1) }
      it { expect(response_json["optOuts"].first["id"]).to eq(opt_out.id) }
      it { expect(response_json["optOuts"].first["email"]).to eq(opt_out.email) }
    end
  end

  describe "GET #potential_subscribers" do
    let(:list)                   { MailyHerald.list :generic_list }
    let!(:subscriber)            { create :user }
    let!(:potential_subscriber)  { create :user }

    before { list.subscribe!(subscriber) && list.reload }

    context "setup" do
      it { expect(list.subscribers).to include(subscriber) }
      it { expect(list.potential_subscribers).to include(potential_subscriber) }
    end

    context "with incorrect MailyHerald::List ID" do
      before { send_request :get, "/maily_herald/api/v1/lists/0/potential_subscribers" }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
    end

    context "with correct MailyHerald::List ID" do
      before { send_request :get, "/maily_herald/api/v1/lists/#{list.id}/potential_subscribers" }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["potentialSubscribers"]).to be_kind_of(Array) }
      it { expect(response_json["potentialSubscribers"].count).to eq(1) }
      it { expect(response_json["potentialSubscribers"].first["id"]).to eq(potential_subscriber.id) }
      it { expect(response_json["potentialSubscribers"].first["email"]).to eq(potential_subscriber.email) }
    end
  end

end

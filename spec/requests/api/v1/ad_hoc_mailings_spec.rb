require "rails_helper"

describe "AdHocMailings API" do

  let(:list) { MailyHerald.list :generic_list }

  describe "GET #index" do
    let!(:ad_hoc_mailing1) { create :ad_hoc_mailing }
    let!(:ad_hoc_mailing2) { create :ad_hoc_mailing, name: "test", title: "test" }

    context "without any params" do
      before { send_request :get, "/maily_herald/api/v1/ad_hoc_mailings/" }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["adHocMailings"].count).to eq(2) }
      it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
      it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
    end

    context "with defined per param" do
      before { send_request :get, "/maily_herald/api/v1/ad_hoc_mailings/", {per: 1} }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["adHocMailings"].count).to eq(1) }
      it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
      it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_truthy }
    end

    context "with defined per and page param" do
      before { send_request :get, "/maily_herald/api/v1/ad_hoc_mailings/", {per: 1, page: 2} }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["adHocMailings"].count).to eq(1) }
      it { expect(response_json["meta"]["pagination"]["page"]).to eq(2) }
      it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
    end

    context "with too high page param" do
      before { send_request :get, "/maily_herald/api/v1/ad_hoc_mailings/", {per: 1, page: 10} }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["adHocMailings"].count).to eq(0) }
      it { expect(response_json["meta"]["pagination"]["page"]).to eq(10) }
      it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
    end

    context "with defined query param" do
      before { send_request :get, "/maily_herald/api/v1/ad_hoc_mailings/", {query: query} }

      context "when query is 'gen'" do
        let(:query) { "test" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["adHocMailings"].count).to eq(1) }
        it { expect(response_json["adHocMailings"].first["name"]).to eq("test") }
        it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
        it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
      end

      context "when query is 'ked'" do
        let(:query) { "ad" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["adHocMailings"].count).to eq(1) }
        it { expect(response_json["adHocMailings"].first["name"]).to eq("ad_hoc_mail") }
        it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
        it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
      end
    end

    context "with 'state' param" do
      context "when 'enabled' or 'disabled'" do
        before do
          ad_hoc_mailing1.disable!
          ad_hoc_mailing1.reload
          expect(MailyHerald::AdHocMailing.enabled.count).to eq(1)
        end

        context "should return enabled mailings" do
          before { send_request :get, "/maily_herald/api/v1/ad_hoc_mailings/", {state: :enabled} }

          it { expect(response.status).to eq(200) }
          it { expect(response).to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["adHocMailings"].count).to eq(1) }
          it { expect(response_json["adHocMailings"].first["state"]).to eq("enabled") }
          it { expect(response_json["adHocMailings"].first["name"]).to eq(ad_hoc_mailing2.name) }
          it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
          it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
        end

        context "should return disabled mailings'" do
          before { send_request :get, "/maily_herald/api/v1/ad_hoc_mailings/", {state: :disabled} }

          it { expect(response.status).to eq(200) }
          it { expect(response).to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["adHocMailings"].count).to eq(1) }
          it { expect(response_json["adHocMailings"].first["state"]).to eq("disabled") }
          it { expect(response_json["adHocMailings"].first["name"]).to eq(ad_hoc_mailing1.name) }
          it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
          it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
        end
      end

      context "when 'archived' or 'not_archived'" do
        before do
          ad_hoc_mailing1.archive!
          ad_hoc_mailing1.reload
          expect(MailyHerald::AdHocMailing.archived.count).to eq(1)
        end

        context "should return archived mailings" do
          before { send_request :get, "/maily_herald/api/v1/ad_hoc_mailings/", {state: :archived} }

          it { expect(response.status).to eq(200) }
          it { expect(response).to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["adHocMailings"].count).to eq(1) }
          it { expect(response_json["adHocMailings"].first["state"]).to eq("archived") }
          it { expect(response_json["adHocMailings"].first["name"]).to eq(ad_hoc_mailing1.name) }
          it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
          it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
        end

        context "should return enabled and disabled mailings" do
          before { send_request :get, "/maily_herald/api/v1/ad_hoc_mailings/", {state: :not_archived} }

          it { expect(response.status).to eq(200) }
          it { expect(response).to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["adHocMailings"].count).to eq(1) }
          it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
          it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
        end
      end
    end

    context "'query' and 'state' combined" do
      before { send_request :get, "/maily_herald/api/v1/ad_hoc_mailings/", {state: :enabled, query: "test"} }

      it { expect(MailyHerald::AdHocMailing.enabled.count).to eq(2) }
      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["adHocMailings"].count).to eq(1) }
      it { expect(response_json["adHocMailings"].first["name"]).to eq(ad_hoc_mailing2.name) }
      it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
      it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
    end
  end

  describe "GET #show" do
    let!(:mailing) { create :ad_hoc_mailing }

    it { expect(MailyHerald::AdHocMailing.count).to eq(1) }

    context "with incorrect AdHocMailing ID" do
      before { send_request :get, "/maily_herald/api/v1/ad_hoc_mailings/0" }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
    end

    context "with correct AdHocMailing ID" do
      before { send_request :get, "/maily_herald/api/v1/ad_hoc_mailings/#{mailing.id}" }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["adHocMailing"]).to eq(
            {
              "id"          =>  mailing.id,
              "listId"      =>  list.id,
              "name"        =>  "ad_hoc_mail",
              "title"       =>  "Ad hoc mailing",
              "subject"     =>  "Hello!",
              "template"    =>  "hello",
              "conditions"  =>  nil,
              "from"        =>  nil,
              "state"       =>  "enabled",
              "mailerName"  =>  "AdHocMailer",
              "locked"      =>  false
           }
         )
        }
    end
  end

  describe "POST #create" do
    it { expect(MailyHerald::AdHocMailing.count).to eq(0) }

    context "with correct params" do
      before { send_request :post, "/maily_herald/api/v1/ad_hoc_mailings", {ad_hoc_mailing: {title: "New adHocMailing", list: "generic_list", subject: "New Subject", template: "Hello!"}}.to_json }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(MailyHerald::AdHocMailing.count).to eq(1) }
      it { expect(response_json["adHocMailing"]["id"]).to eq(MailyHerald::AdHocMailing.first.id) }
      it { expect(response_json["adHocMailing"]["listId"]).to eq(list.id) }
      it { expect(response_json["adHocMailing"]["name"]).to eq("new_adhocmailing") }
      it { expect(response_json["adHocMailing"]["title"]).to eq("New adHocMailing") }
      it { expect(response_json["adHocMailing"]["subject"]).to eq("New Subject") }
      it { expect(response_json["adHocMailing"]["template"]).to eq("Hello!") }
      it { expect(response_json["adHocMailing"]["state"]).to eq("disabled") }
      it { expect(response_json["adHocMailing"]["mailerName"]).to eq("generic") }
      it { expect(response_json["adHocMailing"]["conditions"]).to be_nil }
      it { expect(response_json["adHocMailing"]["from"]).to be_nil }
      it { expect(response_json["adHocMailing"]["locked"]).to be_falsy }
    end

    context "with incorrect params" do
      context "not setup mailer" do
        before { send_request :post, "/maily_herald/api/v1/ad_hoc_mailings", {ad_hoc_mailing: {mailer_name: "wrongOne", title: "New adHocMailing", list: "generic_list", subject: "New Subject", template: "Hello!"}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["mailerName"]).to eq("invalid") }
        it { expect(MailyHerald::AdHocMailing.count).to eq(0) }
      end

      context "wrong template" do
        before { send_request :post, "/maily_herald/api/v1/ad_hoc_mailings", {ad_hoc_mailing: {title: "New adHocMailing", list: "generic_list", subject: "New Subject", template: "Hello {{ world!"}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["template"]).to eq("syntaxError") }
        it { expect(MailyHerald::AdHocMailing.count).to eq(0) }
      end

      context "wrong conditions" do
        before { send_request :post, "/maily_herald/api/v1/ad_hoc_mailings", {ad_hoc_mailing: {title: "New adHocMailing", list: "generic_list", subject: "New Subject", template: "Hello!", conditions: "{{"}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["conditions"]).to eq("notBoolean") }
        it { expect(MailyHerald::AdHocMailing.count).to eq(0) }
      end

      context "nil title" do
        before { send_request :post, "/maily_herald/api/v1/ad_hoc_mailings", {ad_hoc_mailing: {list: "generic_list", subject: "New Subject", template: "Hello!"}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["name"]).to eq("blank") }
        it { expect(response_json["errors"]["title"]).to eq("blank") }
        it { expect(MailyHerald::AdHocMailing.count).to eq(0) }
      end

      context "nil list" do
        before { send_request :post, "/maily_herald/api/v1/ad_hoc_mailings", {ad_hoc_mailing: {title: "New adHocMailing", subject: "New Subject", template: "Hello!"}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["list"]).to eq("blank") }
        it { expect(MailyHerald::AdHocMailing.count).to eq(0) }
      end

      context "nil subject" do
        before { send_request :post, "/maily_herald/api/v1/ad_hoc_mailings", {ad_hoc_mailing: {title: "New adHocMailing", list: "generic_list", template: "Hello!"}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["subject"]).to eq("blank") }
        it { expect(MailyHerald::AdHocMailing.count).to eq(0) }
      end

      context "nil template" do
        before { send_request :post, "/maily_herald/api/v1/ad_hoc_mailings", {ad_hoc_mailing: {title: "New adHocMailing", list: "generic_list", subject: "New Subject"}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["template"]).to eq("blank") }
        it { expect(MailyHerald::AdHocMailing.count).to eq(0) }
      end
    end
  end

  describe "PUT #update" do
    let!(:mailing) { create :ad_hoc_mailing }

    it { expect(MailyHerald::AdHocMailing.count).to eq(1) }

    context "with incorrect AdHocMailing ID" do
      before { send_request :put, "/maily_herald/api/v1/ad_hoc_mailings/0", {ad_hoc_mailing: {subject: "New Subject", template: "New Template", mailer_name: "generic", conditions: "active", state: "enabled"}}.to_json }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
    end

    context "with correct AdHocMailing ID" do
      context "with correct params" do
        before { send_request :put, "/maily_herald/api/v1/ad_hoc_mailings/#{mailing.id}", {ad_hoc_mailing: {subject: "New Subject", template: "New Template", mailer_name: "generic", conditions: "active", state: "enabled"}}.to_json }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["adHocMailing"]["subject"]).to eq("New Subject") }
        it { expect(response_json["adHocMailing"]["template"]).to eq("New Template") }
        it { expect(response_json["adHocMailing"]["state"]).to eq("enabled") }
        it { expect(response_json["adHocMailing"]["mailerName"]).to eq("generic") }
        it { expect(response_json["adHocMailing"]["conditions"]).to eq("active") }
        it { mailing.reload; expect(mailing.subject).to eq("New Subject") }
      end

      context "with incorrect params" do
        context "blanks" do
          before { send_request :put, "/maily_herald/api/v1/ad_hoc_mailings/#{mailing.id}", {ad_hoc_mailing: {title: "", list: ""}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["title"]).to eq("blank") }
          it { expect(response_json["errors"]["list"]).to eq("blank") }
        end

        context "wrong template" do
          before { send_request :put, "/maily_herald/api/v1/ad_hoc_mailings/#{mailing.id}", {ad_hoc_mailing: {template: "{{"}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["template"]).to eq("syntaxError") }
        end

        context "wrong conditions" do
          before { send_request :put, "/maily_herald/api/v1/ad_hoc_mailings/#{mailing.id}", {ad_hoc_mailing: {conditions: "{{"}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["conditions"]).to eq("notBoolean") }
        end

        context "wrong mailer" do
          before { send_request :put, "/maily_herald/api/v1/ad_hoc_mailings/#{mailing.id}", {ad_hoc_mailing: {mailer_name: "{{"}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["mailerName"]).to eq("invalid") }
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:mailing) { create :ad_hoc_mailing }

    it { expect(MailyHerald::AdHocMailing.count).to eq(1) }

    context "with correct AdHocMailing ID" do
      before { send_request :delete, "/maily_herald/api/v1/ad_hoc_mailings/#{list.id}" }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["adHocMailing"]["state"]).to eq("archived") }
      it { expect(MailyHerald::AdHocMailing.count).to eq(1) }
    end

    context "with incorrect AdHocMailing ID" do
      before { send_request :delete, "/maily_herald/api/v1/ad_hoc_mailings/0" }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
      it { mailing.reload; expect(mailing.state.to_s).to eq("enabled") }
      it { expect(MailyHerald::AdHocMailing.count).to eq(1) }
    end
  end

  describe "GET #preview" do
    let!(:mailing) { create :ad_hoc_mailing }
    let!(:entity) { create :user }

    before do
      mailing.list.subscribe! entity
      mailing.reload
    end

    it { expect(MailyHerald::AdHocMailing.count).to eq(1) }
    it { expect(mailing.list.active_subscription_count).to eq(1) }

    context "with incorrect AdHocMailing ID" do
      before { send_request :get, "/maily_herald/api/v1/ad_hoc_mailings/0/preview/#{entity.id}" }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
    end

    context "with incorrect entity ID" do
      before { send_request :get, "/maily_herald/api/v1/ad_hoc_mailings/#{mailing.id}/preview/0" }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
    end

    context "with correct AdHocMailing ID and entity ID" do
      before { send_request :get, "/maily_herald/api/v1/ad_hoc_mailings/#{mailing.id}/preview/#{entity.id}" }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["mailPreview"]).to eq({
             "messageId"=>nil,
             "date"=>nil,
             "headers"=>
              [{"name"=>"From", "value"=>"no-reply@mailyherald.org"},
               {"name"=>"To", "value"=>entity.email},
               {"name"=>"Subject", "value"=>"Test"},
               {"name"=>"Mime-Version", "value"=>"1.0"},
               {"name"=>"Content-Type", "value"=>"text/plain"}],
             "body"=>
              {"charset"=>"US-ASCII", "encoding"=>"7bit", "rawSource"=>"Hello\n\n"}
           })
         }
    end
  end

  describe "POST #deliver" do
    let!(:mailing) { create :ad_hoc_mailing }
    let!(:entity1) { create :user }
    let!(:entity2) { create :user }

    before do
      mailing.list.subscribe! entity1
      mailing.list.subscribe! entity2
      mailing.reload
    end

    it { expect(MailyHerald::AdHocMailing.count).to eq(1) }
    it { expect(mailing.list.active_subscription_count).to eq(2) }
    it { expect(mailing.processable?(entity1)).to be_truthy }
    it { expect(mailing.processable?(entity2)).to be_truthy }
    it { expect(mailing.logs.scheduled.count).to eq(0) }
    it { expect(mailing.logs.processed.count).to eq(0) }

    context "with incorrect AdHocMailing ID" do
      before { send_request :post, "/maily_herald/api/v1/ad_hoc_mailings/0/deliver" }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
    end

    context "with correct AdHocMailing ID" do
      context "with incorrect entity ID" do
        before { send_request :post, "/maily_herald/api/v1/ad_hoc_mailings/#{mailing.id}/deliver/0" }

        it { expect(response.status).to eq(404) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["error"]).to eq("notFound") }
      end

      context "without entity ID" do
        before { send_request :post, "/maily_herald/api/v1/ad_hoc_mailings/#{mailing.id}/deliver" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).to be_empty }

        it { expect(mailing.logs.scheduled.count).to eq(2) }
        it { expect(mailing.logs.processed.count).to eq(0) }
        it { expect(mailing.logs.delivered.count).to eq(0) }

        context "after running delivery" do
          before { mailing.run && mailing.reload }

          it { expect(mailing.logs.processed.count).to eq(2) }
          it { expect(mailing.logs.delivered.count).to eq(2) }
        end
      end

      context "with entity ID" do
        before { send_request :post, "/maily_herald/api/v1/ad_hoc_mailings/#{mailing.id}/deliver/#{entity1.id}" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).to be_empty }

        it { expect(mailing.logs.scheduled.count).to eq(1) }
        it { expect(mailing.logs.processed.count).to eq(0) }
        it { expect(mailing.logs.delivered.count).to eq(0) }
        it { expect(mailing.logs.scheduled.first.entity_id).to eq(entity1.id) }

        context "after running delivery" do
          before { mailing.run && mailing.reload }

          it { expect(mailing.logs.processed.count).to eq(1) }
          it { expect(mailing.logs.delivered.count).to eq(1) }
          it { expect(mailing.logs.delivered.first.entity_id).to eq(entity1.id) }
        end
      end
    end
  end

end

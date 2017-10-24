require "rails_helper"

describe "OneTimeMailings API" do

  describe "GET #index" do
    let!(:mailing1) { create :generic_one_time_mailing }
    let!(:mailing2) { create :generic_one_time_mailing , name: "second_one", title: "second one"}

    it { expect(MailyHerald::OneTimeMailing.count).to eq(3) }

    context "without any params" do
      before { send_request :get, "/maily_herald/api/v1/one_time_mailings" }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["oneTimeMailings"].count).to eq(3) }
      it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
      it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
    end

    context "with defined per param" do
      before { send_request :get, "/maily_herald/api/v1/one_time_mailings", {per: 1} }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["oneTimeMailings"].count).to eq(1) }
      it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
      it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_truthy }
    end

    context "with defined per and page param" do
      before { send_request :get, "/maily_herald/api/v1/one_time_mailings", {per: 1, page: 3} }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["oneTimeMailings"].count).to eq(1) }
      it { expect(response_json["meta"]["pagination"]["page"]).to eq(3) }
      it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
    end

    context "with too high page param" do
      before { send_request :get, "/maily_herald/api/v1/one_time_mailings", {per: 1, page: 10} }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["oneTimeMailings"].count).to eq(0) }
      it { expect(response_json["meta"]["pagination"]["page"]).to eq(10) }
      it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
    end

    context "with defined query param" do
      before { send_request :get, "/maily_herald/api/v1/one_time_mailings", {query: query} }

      context "when query is 'test'" do
        let(:query) { "test" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["oneTimeMailings"].count).to eq(1) }
        it { expect(response_json["oneTimeMailings"].first["name"]).to eq("test_mailing") }
        it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
        it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
      end

      context "when query is 'sec'" do
        let(:query) { "sec" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["oneTimeMailings"].count).to eq(1) }
        it { expect(response_json["oneTimeMailings"].first["name"]).to eq("second_one") }
        it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
        it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
      end
    end

    context "with 'state' param" do
      context "when 'enabled' or 'disabled'" do
        before do
          mailing1.disable!
          mailing1.reload
          expect(MailyHerald::OneTimeMailing.enabled.count).to eq(2)
        end

        context "should return enabled mailings" do
          before { send_request :get, "/maily_herald/api/v1/one_time_mailings", {state: :enabled} }

          it { expect(response.status).to eq(200) }
          it { expect(response).to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["oneTimeMailings"].count).to eq(2) }
          it { expect(response_json["oneTimeMailings"].first["state"]).to eq("enabled") }
          it { expect(response_json["oneTimeMailings"].first["name"]).to eq("locked_mailing") }
          it { expect(response_json["oneTimeMailings"].second["state"]).to eq("enabled") }
          it { expect(response_json["oneTimeMailings"].second["name"]).to eq(mailing2.name) }
          it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
          it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
        end

        context "should return disabled mailings'" do
          before { send_request :get, "/maily_herald/api/v1/one_time_mailings", {state: :disabled} }

          it { expect(response.status).to eq(200) }
          it { expect(response).to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["oneTimeMailings"].count).to eq(1) }
          it { expect(response_json["oneTimeMailings"].first["state"]).to eq("disabled") }
          it { expect(response_json["oneTimeMailings"].first["name"]).to eq(mailing1.name) }
          it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
          it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
        end
      end

      context "when 'archived' or 'not_archived'" do
        before do
          mailing1.archive!
          mailing1.reload
          expect(MailyHerald::OneTimeMailing.archived.count).to eq(1)
        end

        context "should return archived mailings" do
          before { send_request :get, "/maily_herald/api/v1/one_time_mailings", {state: :archived} }

          it { expect(response.status).to eq(200) }
          it { expect(response).to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["oneTimeMailings"].count).to eq(1) }
          it { expect(response_json["oneTimeMailings"].first["state"]).to eq("archived") }
          it { expect(response_json["oneTimeMailings"].first["name"]).to eq(mailing1.name) }
          it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
          it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
        end

        context "should return enabled and disabled mailings" do
          before { send_request :get, "/maily_herald/api/v1/one_time_mailings", {state: :not_archived} }

          it { expect(response.status).to eq(200) }
          it { expect(response).to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["oneTimeMailings"].count).to eq(2) }
          it { expect(response_json["oneTimeMailings"].first["state"]).to eq("enabled") }
          it { expect(response_json["oneTimeMailings"].first["name"]).to eq("locked_mailing") }
          it { expect(response_json["oneTimeMailings"].second["state"]).to eq("enabled") }
          it { expect(response_json["oneTimeMailings"].second["name"]).to eq(mailing2.name) }
          it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
          it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
        end
      end
    end

    context "'query' and 'state' combined" do
      before { send_request :get, "/maily_herald/api/v1/one_time_mailings", {state: :enabled, query: "second"} }

      it { expect(MailyHerald::OneTimeMailing.enabled.count).to eq(3) }
      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["oneTimeMailings"].count).to eq(1) }
      it { expect(response_json["oneTimeMailings"].first["name"]).to eq(mailing2.name) }
      it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
      it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
    end
  end

  describe "GET #show" do
    let!(:mailing) { MailyHerald.one_time_mailing :locked_mailing }
    let(:list)     { mailing.list }

    it { expect(MailyHerald::OneTimeMailing.count).to eq(1) }

    context "with incorrect OneTimeMailing ID" do
      before { send_request :get, "/maily_herald/api/v1/one_time_mailings/0" }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
    end

    context "with correct OneTimeMailing ID" do
      before { send_request :get, "/maily_herald/api/v1/one_time_mailings/#{mailing.id}" }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["oneTimeMailing"]).to eq(
            {
              "id"          =>  mailing.id,
              "listId"      =>  list.id,
              "name"        =>  "locked_mailing",
              "title"       =>  "Locked mailing",
              "subject"     =>  "Locked mailing",
              "template"    =>  "User name: {{user.name}}.",
              "conditions"  =>  nil,
              "from"        =>  nil,
              "state"       =>  "enabled",
              "mailerName"  =>  "generic",
              "startAt"     =>  "user.created_at",
              "locked"      =>  true
           }
         )
        }
    end
  end

  describe "POST #create" do
    let(:list)     { MailyHerald.list :generic_list }
    let(:start_at) { Time.now + 1.minute }

    it { expect(MailyHerald::OneTimeMailing.count).to eq(1) }

    context "with correct params" do
      before { send_request :post, "/maily_herald/api/v1/one_time_mailings", {one_time_mailing: {title: "New oneTimeMailing", list: "generic_list", subject: "New Subject", template: "Hello!", start_at: start_at}}.to_json }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(MailyHerald::OneTimeMailing.count).to eq(2) }
      it { expect(response_json["oneTimeMailing"]["id"]).to eq(MailyHerald::OneTimeMailing.where(name: "new_onetimemailing").first.id) }
      it { expect(response_json["oneTimeMailing"]["listId"]).to eq(list.id) }
      it { expect(response_json["oneTimeMailing"]["name"]).to eq("new_onetimemailing") }
      it { expect(response_json["oneTimeMailing"]["title"]).to eq("New oneTimeMailing") }
      it { expect(response_json["oneTimeMailing"]["subject"]).to eq("New Subject") }
      it { expect(response_json["oneTimeMailing"]["template"]).to eq("Hello!") }
      it { expect(response_json["oneTimeMailing"]["state"]).to eq("disabled") }
      it { expect(response_json["oneTimeMailing"]["mailerName"]).to eq("generic") }
      it { expect(response_json["oneTimeMailing"]["conditions"]).to be_nil }
      it { expect(response_json["oneTimeMailing"]["from"]).to be_nil }
      it { expect(response_json["oneTimeMailing"]["startAt"]).to eq(start_at.as_json) }
      it { expect(response_json["oneTimeMailing"]["locked"]).to be_falsy }
    end

    context "with incorrect params" do
      context "not setup mailer" do
        before { send_request :post, "/maily_herald/api/v1/one_time_mailings", {one_time_mailing: {mailer_name: "wrongOne", title: "New oneTimeMailing", list: "generic_list", subject: "New Subject", template: "Hello!", start_at: start_at}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["mailerName"]).to eq("invalid") }
        it { expect(MailyHerald::OneTimeMailing.count).to eq(1) }
      end

      context "wrong template" do
        before { send_request :post, "/maily_herald/api/v1/one_time_mailings", {one_time_mailing: {title: "New oneTimeMailing", list: "generic_list", subject: "New Subject", template: "Hello {{ world!", start_at: start_at}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["template"]).to eq("syntaxError") }
        it { expect(MailyHerald::OneTimeMailing.count).to eq(1) }
      end

      context "wrong conditions" do
        before { send_request :post, "/maily_herald/api/v1/one_time_mailings", {one_time_mailing: {title: "New oneTimeMailing", list: "generic_list", subject: "New Subject", template: "Hello!", conditions: "{{", start_at: start_at}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["conditions"]).to eq("notBoolean") }
        it { expect(MailyHerald::OneTimeMailing.count).to eq(1) }
      end

      context "nil title" do
        before { send_request :post, "/maily_herald/api/v1/one_time_mailings", {one_time_mailing: {list: "generic_list", subject: "New Subject", template: "Hello!", start_at: start_at}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["name"]).to eq("blank") }
        it { expect(response_json["errors"]["title"]).to eq("blank") }
        it { expect(MailyHerald::OneTimeMailing.count).to eq(1) }
      end

      context "nil list" do
        before { send_request :post, "/maily_herald/api/v1/one_time_mailings", {one_time_mailing: {title: "New oneTimeMailing", subject: "New Subject", template: "Hello!", start_at: start_at}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["list"]).to eq("blank") }
        it { expect(MailyHerald::OneTimeMailing.count).to eq(1) }
      end

      context "nil subject" do
        before { send_request :post, "/maily_herald/api/v1/one_time_mailings", {one_time_mailing: {title: "New oneTimeMailing", list: "generic_list", template: "Hello!", start_at: start_at}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["subject"]).to eq("blank") }
        it { expect(MailyHerald::OneTimeMailing.count).to eq(1) }
      end

      context "nil template" do
        before { send_request :post, "/maily_herald/api/v1/one_time_mailings", {one_time_mailing: {title: "New oneTimeMailing", list: "generic_list", subject: "New Subject", start_at: start_at}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["template"]).to eq("blank") }
        it { expect(MailyHerald::OneTimeMailing.count).to eq(1) }
      end

      context "nil start_at" do
        before { send_request :post, "/maily_herald/api/v1/one_time_mailings", {one_time_mailing: {title: "New oneTimeMailing", list: "generic_list", subject: "New Subject", template: "Hello!"}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["startAt"]).to eq("blank") }
        it { expect(MailyHerald::OneTimeMailing.count).to eq(1) }
      end

      context "wrong start_at" do
        before { send_request :post, "/maily_herald/api/v1/one_time_mailings", {one_time_mailing: {title: "New oneTimeMailing", list: "generic_list", subject: "New Subject", template: "Hello!", start_at: "{{"}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["startAt"]).to eq("notTime") }
        it { expect(MailyHerald::OneTimeMailing.count).to eq(1) }
      end
    end
  end

  describe "PUT #update" do
    let!(:mailing) { create :generic_one_time_mailing }

    it { expect(MailyHerald::OneTimeMailing.count).to eq(2) }

    context "with incorrect OneTimeMailing ID" do
      before { send_request :put, "/maily_herald/api/v1/one_time_mailings/0", {one_time_mailing: {subject: "New Subject", template: "New Template", mailer_name: "generic", conditions: "active", state: "enabled"}}.to_json }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
    end

    context "with correct OneTimeMailing ID" do
      context "with correct params" do
        context "not locked mailing" do
          before { send_request :put, "/maily_herald/api/v1/one_time_mailings/#{mailing.id}", {one_time_mailing: {subject: "New Subject", template: "New Template", mailer_name: "generic", conditions: "active", state: "enabled"}}.to_json }

          it { expect(response.status).to eq(200) }
          it { expect(response).to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["oneTimeMailing"]["subject"]).to eq("New Subject") }
          it { expect(response_json["oneTimeMailing"]["template"]).to eq("New Template") }
          it { expect(response_json["oneTimeMailing"]["state"]).to eq("enabled") }
          it { expect(response_json["oneTimeMailing"]["mailerName"]).to eq("generic") }
          it { expect(response_json["oneTimeMailing"]["conditions"]).to eq("active") }
          it { mailing.reload; expect(mailing.subject).to eq("New Subject") }
        end

        context "locked mailing" do
          let!(:mailing) { MailyHerald.one_time_mailing :locked_mailing }

          before { send_request :put, "/maily_herald/api/v1/one_time_mailings/#{mailing.id}", {one_time_mailing: {subject: "New Subject", template: "New Template", mailer_name: "generic", conditions: "active", state: "enabled"}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["base"]).to eq("locked") }
          it { mailing.reload; expect(mailing.subject).not_to eq("New Subject") }
        end
      end

      context "with incorrect params" do
        context "blanks" do
          before { send_request :put, "/maily_herald/api/v1/one_time_mailings/#{mailing.id}", {one_time_mailing: {title: "", list: ""}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["title"]).to eq("blank") }
          it { expect(response_json["errors"]["list"]).to eq("blank") }
        end

        context "wrong template" do
          before { send_request :put, "/maily_herald/api/v1/one_time_mailings/#{mailing.id}", {one_time_mailing: {template: "{{"}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["template"]).to eq("syntaxError") }
        end

        context "wrong conditions" do
          before { send_request :put, "/maily_herald/api/v1/one_time_mailings/#{mailing.id}", {one_time_mailing: {conditions: "{{"}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["conditions"]).to eq("notBoolean") }
        end

        context "wrong mailer" do
          before { send_request :put, "/maily_herald/api/v1/one_time_mailings/#{mailing.id}", {one_time_mailing: {mailer_name: "{{"}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["mailerName"]).to eq("invalid") }
        end

        context "blank start_at" do
          before { send_request :put, "/maily_herald/api/v1/one_time_mailings/#{mailing.id}", {one_time_mailing: {start_at: ""}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["startAt"]).to eq("blank") }
        end

        context "wrong start_at" do
          before { send_request :put, "/maily_herald/api/v1/one_time_mailings/#{mailing.id}", {one_time_mailing: {start_at: "{{"}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["startAt"]).to eq("notTime") }
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:mailing) { create :generic_one_time_mailing }

    it { expect(MailyHerald::OneTimeMailing.count).to eq(2) }

    context "with correct OneTimeMailing ID" do
      before { send_request :delete, "/maily_herald/api/v1/one_time_mailings/#{mailing.id}" }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["oneTimeMailing"]["state"]).to eq("archived") }
      it { expect(MailyHerald::OneTimeMailing.count).to eq(2) }
    end

    context "with incorrect OneTimeMailing ID" do
      before { send_request :delete, "/maily_herald/api/v1/one_time_mailings/0" }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
      it { mailing.reload; expect(mailing.state.to_s).to eq("enabled") }
      it { expect(MailyHerald::OneTimeMailing.count).to eq(2) }
    end
  end

  describe "GET #preview" do
    let!(:mailing) { create :generic_one_time_mailing }
    let!(:entity) { create :user }

    before do
      mailing.list.subscribe! entity
      mailing.reload
    end

    it { expect(MailyHerald::OneTimeMailing.count).to eq(2) }
    it { expect(mailing.list.active_subscription_count).to eq(1) }

    context "with incorrect OneTimeMailing ID" do
      before { send_request :get, "/maily_herald/api/v1/one_time_mailings/0/preview/#{entity.id}" }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
    end

    context "with incorrect entity ID" do
      before { send_request :get, "/maily_herald/api/v1/one_time_mailings/#{mailing.id}/preview/0" }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
    end

    context "with correct OneTimeMailing ID and entity ID" do
      before { send_request :get, "/maily_herald/api/v1/one_time_mailings/#{mailing.id}/preview/#{entity.id}" }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["mailPreview"]).to eq({
             "messageId"  =>  nil,
             "date"       =>  nil,
             "headers"    =>  [
                                {"name"=>"From"          , "value"=>mailing.from},
                                {"name"=>"To"            , "value"=>entity.email},
                                {"name"=>"Subject"       , "value"=>mailing.subject},
                                {"name"=>"Mime-Version"  , "value"=>"1.0"},
                                {"name"=>"Content-Type"  , "value"=>"text/plain"}
                              ],
             "body"       =>  {
                                "charset"   =>  "US-ASCII",
                                "encoding"  =>  "7bit",
                                "rawSource" =>  "User name: #{entity.name}."
                              }
           })
         }
    end
  end

end

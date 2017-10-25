require "rails_helper"

describe "PeriodicalMailings API" do

  describe "GET #index" do
    let!(:mailing1) { create :weekly_summary }
    let!(:mailing2) { create :weekly_summary , name: "second_one", title: "second one"}

    it { expect(MailyHerald::PeriodicalMailing.count).to eq(2) }

    context "without any params" do
      before { send_request :get, "/maily_herald/api/v1/periodical_mailings" }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["periodicalMailings"].count).to eq(2) }
      it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
      it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
    end

    context "with defined per param" do
      before { send_request :get, "/maily_herald/api/v1/periodical_mailings", {per: 1} }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["periodicalMailings"].count).to eq(1) }
      it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
      it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_truthy }
    end

    context "with defined per and page param" do
      before { send_request :get, "/maily_herald/api/v1/periodical_mailings", {per: 1, page: 2} }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["periodicalMailings"].count).to eq(1) }
      it { expect(response_json["meta"]["pagination"]["page"]).to eq(2) }
      it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
    end

    context "with too high page param" do
      before { send_request :get, "/maily_herald/api/v1/periodical_mailings", {per: 1, page: 10} }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["periodicalMailings"].count).to eq(0) }
      it { expect(response_json["meta"]["pagination"]["page"]).to eq(10) }
      it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
    end

    context "with defined query param" do
      before { send_request :get, "/maily_herald/api/v1/periodical_mailings", {query: query} }

      context "when query is 'week'" do
        let(:query) { "week" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["periodicalMailings"].count).to eq(1) }
        it { expect(response_json["periodicalMailings"].first["name"]).to eq("weekly_summary") }
        it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
        it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
      end

      context "when query is 'sec'" do
        let(:query) { "sec" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["periodicalMailings"].count).to eq(1) }
        it { expect(response_json["periodicalMailings"].first["name"]).to eq("second_one") }
        it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
        it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
      end
    end

    context "with 'state' param" do
      context "when 'enabled' or 'disabled'" do
        before do
          mailing1.disable!
          mailing1.reload
          expect(MailyHerald::PeriodicalMailing.enabled.count).to eq(1)
        end

        context "should return enabled mailings" do
          before { send_request :get, "/maily_herald/api/v1/periodical_mailings", {state: :enabled} }

          it { expect(response.status).to eq(200) }
          it { expect(response).to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["periodicalMailings"].count).to eq(1) }
          it { expect(response_json["periodicalMailings"].first["state"]).to eq("enabled") }
          it { expect(response_json["periodicalMailings"].first["name"]).to eq(mailing2.name) }
          it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
          it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
        end

        context "should return disabled mailings'" do
          before { send_request :get, "/maily_herald/api/v1/periodical_mailings", {state: :disabled} }

          it { expect(response.status).to eq(200) }
          it { expect(response).to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["periodicalMailings"].count).to eq(1) }
          it { expect(response_json["periodicalMailings"].first["state"]).to eq("disabled") }
          it { expect(response_json["periodicalMailings"].first["name"]).to eq(mailing1.name) }
          it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
          it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
        end
      end

      context "when 'archived' or 'not_archived'" do
        before do
          mailing1.archive!
          mailing1.reload
          expect(MailyHerald::PeriodicalMailing.archived.count).to eq(1)
        end

        context "should return archived mailings" do
          before { send_request :get, "/maily_herald/api/v1/periodical_mailings", {state: :archived} }

          it { expect(response.status).to eq(200) }
          it { expect(response).to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["periodicalMailings"].count).to eq(1) }
          it { expect(response_json["periodicalMailings"].first["state"]).to eq("archived") }
          it { expect(response_json["periodicalMailings"].first["name"]).to eq(mailing1.name) }
          it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
          it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
        end

        context "should return enabled and disabled mailings" do
          before { send_request :get, "/maily_herald/api/v1/periodical_mailings", {state: :not_archived} }

          it { expect(response.status).to eq(200) }
          it { expect(response).to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["periodicalMailings"].count).to eq(1) }
          it { expect(response_json["periodicalMailings"].first["state"]).to eq("enabled") }
          it { expect(response_json["periodicalMailings"].first["name"]).to eq(mailing2.name) }
          it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
          it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
        end
      end
    end

    context "'query' and 'state' combined" do
      before { send_request :get, "/maily_herald/api/v1/periodical_mailings", {state: :enabled, query: "second"} }

      it { expect(MailyHerald::PeriodicalMailing.enabled.count).to eq(2) }
      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["periodicalMailings"].count).to eq(1) }
      it { expect(response_json["periodicalMailings"].first["name"]).to eq(mailing2.name) }
      it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
      it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
    end
  end

  describe "GET #show" do
    let!(:mailing) { create :weekly_summary }
    let(:list)     { mailing.list }

    it { expect(MailyHerald::PeriodicalMailing.count).to eq(1) }

    context "with incorrect PeriodicalMailing ID" do
      before { send_request :get, "/maily_herald/api/v1/periodical_mailings/0" }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
    end

    context "with correct PeriodicalMailing ID" do
      before { send_request :get, "/maily_herald/api/v1/periodical_mailings/#{mailing.id}" }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["periodicalMailing"]).to eq(
            {
              "id"            =>  mailing.id,
              "listId"        =>  list.id,
              "name"          =>  "weekly_summary",
              "title"         =>  "Test periodical mailing",
              "subject"       =>  "Weekly summary",
              "template"      =>  "User name: {{user.name}}.",
              "conditions"    =>  "user.weekly_notifications == true",
              "from"          =>  nil,
              "state"         =>  "enabled",
              "mailerName"    =>  "generic",
              "startAt"       =>  "user.created_at",
              "locked"        =>  false,
              "periodInDays"  =>  "7.00"
           }
         )
        }
    end
  end

  describe "POST #create" do
    let(:list)     { MailyHerald.list :generic_list }
    let(:start_at) { Time.now + 1.minute }

    it { expect(MailyHerald::PeriodicalMailing.count).to eq(0) }

    context "with correct params" do
      before { send_request :post, "/maily_herald/api/v1/periodical_mailings", {periodical_mailing: {title: "New periodicalMailing", list: "generic_list", subject: "New Subject", template: "Hello!", start_at: start_at, period_in_days: 7}}.to_json }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(MailyHerald::PeriodicalMailing.count).to eq(1) }
      it { expect(response_json["periodicalMailing"]["id"]).to eq(MailyHerald::PeriodicalMailing.where(name: "new_periodicalmailing").first.id) }
      it { expect(response_json["periodicalMailing"]["listId"]).to eq(list.id) }
      it { expect(response_json["periodicalMailing"]["name"]).to eq("new_periodicalmailing") }
      it { expect(response_json["periodicalMailing"]["title"]).to eq("New periodicalMailing") }
      it { expect(response_json["periodicalMailing"]["subject"]).to eq("New Subject") }
      it { expect(response_json["periodicalMailing"]["template"]).to eq("Hello!") }
      it { expect(response_json["periodicalMailing"]["state"]).to eq("disabled") }
      it { expect(response_json["periodicalMailing"]["mailerName"]).to eq("generic") }
      it { expect(response_json["periodicalMailing"]["conditions"]).to be_nil }
      it { expect(response_json["periodicalMailing"]["from"]).to be_nil }
      it { expect(response_json["periodicalMailing"]["startAt"]).to eq(start_at.as_json) }
      it { expect(response_json["periodicalMailing"]["locked"]).to be_falsy }
      it { expect(response_json["periodicalMailing"]["periodInDays"]).to eq("7.00") }
    end

    context "with incorrect params" do
      context "not setup mailer" do
        before { send_request :post, "/maily_herald/api/v1/periodical_mailings", {periodical_mailing: {mailer_name: "wrongOne", title: "New periodicalMailing", list: "generic_list", subject: "New Subject", template: "Hello!", start_at: start_at, period_in_days: 7}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["mailerName"]).to eq("invalid") }
        it { expect(MailyHerald::PeriodicalMailing.count).to eq(0) }
      end

      context "wrong template" do
        before { send_request :post, "/maily_herald/api/v1/periodical_mailings", {periodical_mailing: {title: "New periodicalMailing", list: "generic_list", subject: "New Subject", template: "Hello {{ world!", start_at: start_at, period_in_days: 7}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["template"]).to eq("syntaxError") }
        it { expect(MailyHerald::PeriodicalMailing.count).to eq(0) }
      end

      context "wrong conditions" do
        before { send_request :post, "/maily_herald/api/v1/periodical_mailings", {periodical_mailing: {title: "New periodicalMailing", list: "generic_list", subject: "New Subject", template: "Hello!", conditions: "{{", start_at: start_at, period_in_days: 7}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["conditions"]).to eq("notBoolean") }
        it { expect(MailyHerald::PeriodicalMailing.count).to eq(0) }
      end

      context "nil title" do
        before { send_request :post, "/maily_herald/api/v1/periodical_mailings", {periodical_mailing: {list: "generic_list", subject: "New Subject", template: "Hello!", start_at: start_at, period_in_days: 7}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["name"]).to eq("blank") }
        it { expect(response_json["errors"]["title"]).to eq("blank") }
        it { expect(MailyHerald::PeriodicalMailing.count).to eq(0) }
      end

      context "nil list" do
        before { send_request :post, "/maily_herald/api/v1/periodical_mailings", {periodical_mailing: {title: "New periodicalMailing", subject: "New Subject", template: "Hello!", start_at: start_at, period_in_days: 7}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["list"]).to eq("blank") }
        it { expect(MailyHerald::PeriodicalMailing.count).to eq(0) }
      end

      context "nil subject" do
        before { send_request :post, "/maily_herald/api/v1/periodical_mailings", {periodical_mailing: {title: "New periodicalMailing", list: "generic_list", template: "Hello!", start_at: start_at, period_in_days: 7}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["subject"]).to eq("blank") }
        it { expect(MailyHerald::PeriodicalMailing.count).to eq(0) }
      end

      context "nil template" do
        before { send_request :post, "/maily_herald/api/v1/periodical_mailings", {periodical_mailing: {title: "New periodicalMailing", list: "generic_list", subject: "New Subject", start_at: start_at, period_in_days: 7}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["template"]).to eq("blank") }
        it { expect(MailyHerald::PeriodicalMailing.count).to eq(0) }
      end

      context "nil start_at" do
        before { send_request :post, "/maily_herald/api/v1/periodical_mailings", {periodical_mailing: {title: "New periodicalMailing", list: "generic_list", subject: "New Subject", template: "Hello!", period_in_days: 7}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["startAt"]).to eq("blank") }
        it { expect(MailyHerald::PeriodicalMailing.count).to eq(0) }
      end

      context "wrong start_at" do
        before { send_request :post, "/maily_herald/api/v1/periodical_mailings", {periodical_mailing: {title: "New periodicalMailing", list: "generic_list", subject: "New Subject", template: "Hello!", start_at: "{{", period_in_days: 7}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["startAt"]).to eq("notTime") }
        it { expect(MailyHerald::PeriodicalMailing.count).to eq(0) }
      end

      context "nil period_in_days" do
        before { send_request :post, "/maily_herald/api/v1/periodical_mailings", {periodical_mailing: {title: "New periodicalMailing", list: "generic_list", subject: "New Subject", template: "Hello!", start_at: start_at}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["period"]).to eq("blank") }
        it { expect(MailyHerald::PeriodicalMailing.count).to eq(0) }
      end

      context "wrong period_in_days - string" do
        before { send_request :post, "/maily_herald/api/v1/periodical_mailings", {periodical_mailing: {title: "New periodicalMailing", list: "generic_list", subject: "New Subject", template: "Hello!", start_at: start_at, period_in_days: "wrongOne"}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["period"]).to eq("greaterThan0") }
        it { expect(MailyHerald::PeriodicalMailing.count).to eq(0) }
      end

      context "wrong period_in_days - 0" do
        before { send_request :post, "/maily_herald/api/v1/periodical_mailings", {periodical_mailing: {title: "New periodicalMailing", list: "generic_list", subject: "New Subject", template: "Hello!", start_at: "{{", period_in_days: 0}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["period"]).to eq("greaterThan0") }
        it { expect(MailyHerald::PeriodicalMailing.count).to eq(0) }
      end
    end
  end

  describe "PUT #update" do
    let!(:mailing) { create :weekly_summary }

    it { expect(MailyHerald::PeriodicalMailing.count).to eq(1) }

    context "with incorrect PeriodicalMailing ID" do
      before { send_request :put, "/maily_herald/api/v1/periodical_mailings/0", {periodical_mailing: {subject: "New Subject", template: "New Template", mailer_name: "generic", conditions: "active", state: "enabled", period_in_days: 10}}.to_json }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
    end

    context "with correct PeriodicalMailing ID" do
      context "with correct params" do
        context "not locked mailing" do
          before { send_request :put, "/maily_herald/api/v1/periodical_mailings/#{mailing.id}", {periodical_mailing: {subject: "New Subject", template: "New Template", mailer_name: "generic", conditions: "active", state: "enabled", period_in_days: 10}}.to_json }

          it { expect(response.status).to eq(200) }
          it { expect(response).to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["periodicalMailing"]["subject"]).to eq("New Subject") }
          it { expect(response_json["periodicalMailing"]["template"]).to eq("New Template") }
          it { expect(response_json["periodicalMailing"]["state"]).to eq("enabled") }
          it { expect(response_json["periodicalMailing"]["mailerName"]).to eq("generic") }
          it { expect(response_json["periodicalMailing"]["conditions"]).to eq("active") }
          it { expect(response_json["periodicalMailing"]["periodInDays"]).to eq("10.00") }
          it { mailing.reload; expect(mailing.subject).to eq("New Subject") }
        end
      end

      context "with incorrect params" do
        context "blanks" do
          before { send_request :put, "/maily_herald/api/v1/periodical_mailings/#{mailing.id}", {periodical_mailing: {title: "", list: ""}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["title"]).to eq("blank") }
          it { expect(response_json["errors"]["list"]).to eq("blank") }
        end

        context "wrong template" do
          before { send_request :put, "/maily_herald/api/v1/periodical_mailings/#{mailing.id}", {periodical_mailing: {template: "{{"}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["template"]).to eq("syntaxError") }
        end

        context "wrong conditions" do
          before { send_request :put, "/maily_herald/api/v1/periodical_mailings/#{mailing.id}", {periodical_mailing: {conditions: "{{"}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["conditions"]).to eq("notBoolean") }
        end

        context "wrong mailer" do
          before { send_request :put, "/maily_herald/api/v1/periodical_mailings/#{mailing.id}", {periodical_mailing: {mailer_name: "{{"}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["mailerName"]).to eq("invalid") }
        end

        context "blank start_at" do
          before { send_request :put, "/maily_herald/api/v1/periodical_mailings/#{mailing.id}", {periodical_mailing: {start_at: ""}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["startAt"]).to eq("blank") }
        end

        context "wrong start_at" do
          before { send_request :put, "/maily_herald/api/v1/periodical_mailings/#{mailing.id}", {periodical_mailing: {start_at: "{{"}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["startAt"]).to eq("notTime") }
        end

        context "wrong period_in_days" do
          before { send_request :put, "/maily_herald/api/v1/periodical_mailings/#{mailing.id}", {periodical_mailing: {period_in_days: 0}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["period"]).to eq("greaterThan0") }
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:mailing) { create :weekly_summary }

    it { expect(MailyHerald::PeriodicalMailing.count).to eq(1) }

    context "with correct PeriodicalMailing ID" do
      before { send_request :delete, "/maily_herald/api/v1/periodical_mailings/#{mailing.id}" }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["periodicalMailing"]["state"]).to eq("archived") }
      it { expect(MailyHerald::PeriodicalMailing.count).to eq(1) }
    end

    context "with incorrect PeriodicalMailing ID" do
      before { send_request :delete, "/maily_herald/api/v1/periodical_mailings/0" }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
      it { mailing.reload; expect(mailing.state.to_s).to eq("enabled") }
      it { expect(MailyHerald::PeriodicalMailing.count).to eq(1) }
    end
  end

  describe "GET #preview" do
    let!(:mailing) { create :weekly_summary }
    let!(:entity) { create :user }

    before do
      mailing.list.subscribe! entity
      mailing.reload
    end

    it { expect(MailyHerald::PeriodicalMailing.count).to eq(1) }
    it { expect(mailing.list.active_subscription_count).to eq(1) }

    context "with incorrect PeriodicalMailing ID" do
      before { send_request :get, "/maily_herald/api/v1/periodical_mailings/0/preview/#{entity.id}" }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
    end

    context "with incorrect PeriodicalMailing ID" do
      before { send_request :get, "/maily_herald/api/v1/periodical_mailings/#{mailing.id}/preview/0" }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
    end

    context "with correct PeriodicalMailing ID and entity ID" do
      before { send_request :get, "/maily_herald/api/v1/periodical_mailings/#{mailing.id}/preview/#{entity.id}" }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["mailPreview"]).to eq({
             "messageId"  =>  nil,
             "date"       =>  nil,
             "headers"    =>  [
                                {"name"=>"From"          , "value"=>""},
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

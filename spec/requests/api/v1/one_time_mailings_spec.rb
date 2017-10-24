require "rails_helper"

describe "OneTimeMailings API" do

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
              "startAt"     =>  "user.created_at"
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

end

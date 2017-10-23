require "rails_helper"

describe "AdHocMailings API" do

  let(:list) { MailyHerald.list :generic_list }

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
              "id"=>mailing.id,
              "listId"=>list.id,
              "name"=>"ad_hoc_mail",
              "title"=>"Ad hoc mailing",
              "subject"=>"Hello!",
              "template"=>"hello",
              "conditions"=>nil,
              "from"=>nil,
              "state"=>"enabled",
              "mailerName"=>"AdHocMailer"
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

end

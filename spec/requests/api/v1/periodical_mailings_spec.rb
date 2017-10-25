require "rails_helper"

describe "PeriodicalMailings API" do

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

end

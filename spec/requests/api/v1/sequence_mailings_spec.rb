require "rails_helper"

describe "SequenceMailings API" do

  let!(:sequence) { create :clean_sequence }

  it { expect(MailyHerald::Sequence.count).to eq(1) }
  it { expect(MailyHerald::SequenceMailing.count).to eq(0) }

  describe "POST #create" do
    context "with incorrect sequence ID" do
          before { send_request :post, "/maily_herald/api/v1/sequences/0/mailings", {sequence_mailing: {title: "New sequenceMailing", subject: "New Subject", template: "Hello!", absolute_delay_in_days: 0.04}}.to_json }

          it { expect(response.status).to eq(404) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["error"]).to eq("notFound") }
          it { expect(MailyHerald::SequenceMailing.count).to eq(0) }
    end

    context "with correct sequence ID" do
      context "with correct params" do
        before { send_request :post, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings", {sequence_mailing: {title: "New sequenceMailing", subject: "New Subject", template: "Hello!", absolute_delay_in_days: 0.04}}.to_json }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(MailyHerald::SequenceMailing.count).to eq(1) }
        it { sequence.reload; expect(sequence.mailings.count).to eq(1) }
        it { expect(response_json["sequenceMailing"]["id"]).to eq(MailyHerald::SequenceMailing.where(name: "new_sequencemailing").first.id) }
        it { expect(response_json["sequenceMailing"]["sequenceId"]).to eq(sequence.id) }
        it { expect(response_json["sequenceMailing"]["name"]).to eq("new_sequencemailing") }
        it { expect(response_json["sequenceMailing"]["title"]).to eq("New sequenceMailing") }
        it { expect(response_json["sequenceMailing"]["subject"]).to eq("New Subject") }
        it { expect(response_json["sequenceMailing"]["template"]).to eq("Hello!") }
        it { expect(response_json["sequenceMailing"]["state"]).to eq("disabled") }
        it { expect(response_json["sequenceMailing"]["mailerName"]).to eq("generic") }
        it { expect(response_json["sequenceMailing"]["conditions"]).to be_nil }
        it { expect(response_json["sequenceMailing"]["from"]).to be_nil }
        it { expect(response_json["sequenceMailing"]["locked"]).to be_falsy }
        it { expect(response_json["sequenceMailing"]["absoluteDelayInDays"]).to eq("0.04") }
      end

      context "with incorrect params" do
        context "not setup mailer" do
          before { send_request :post, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings", {sequence_mailing: {mailer_name: "wrongOne", title: "New sequenceMailing", subject: "New Subject", template: "Hello!", absolute_delay_in_days: 0.04}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["mailerName"]).to eq("invalid") }
          it { expect(MailyHerald::SequenceMailing.count).to eq(0) }
        end

        context "wrong template" do
          before { send_request :post, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings", {sequence_mailing: {mailer_name: "wrongOne", title: "New sequenceMailing", subject: "New Subject", template: "{{", absolute_delay_in_days: 0.04}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["template"]).to eq("syntaxError") }
          it { expect(MailyHerald::SequenceMailing.count).to eq(0) }
        end

        context "wrong conditions" do
          before { send_request :post, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings", {sequence_mailing: {title: "New sequenceMailing", subject: "New Subject", template: "Hello!", conditions: "{{", absolute_delay_in_days: 0.04}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["conditions"]).to eq("notBoolean") }
          it { expect(MailyHerald::SequenceMailing.count).to eq(0) }
        end

        context "nil title" do
          before { send_request :post, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings", {sequence_mailing: {subject: "New Subject", template: "Hello!", absolute_delay_in_days: 0.04}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["name"]).to eq("blank") }
          it { expect(response_json["errors"]["title"]).to eq("blank") }
          it { expect(MailyHerald::SequenceMailing.count).to eq(0) }
        end

        context "nil subject" do
          before { send_request :post, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings", {sequence_mailing: {title: "New sequenceMailing", template: "Hello!", absolute_delay_in_days: 0.04}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["subject"]).to eq("blank") }
          it { expect(MailyHerald::SequenceMailing.count).to eq(0) }
        end

        context "nil template" do
          before { send_request :post, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings", {sequence_mailing: {title: "New sequenceMailing", subject: "New Subject", absolute_delay_in_days: 0.04}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["template"]).to eq("blank") }
          it { expect(MailyHerald::SequenceMailing.count).to eq(0) }
        end

        context "nil absolute_delay_in_days" do
          before { send_request :post, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings", {sequence_mailing: {title: "New sequenceMailing", subject: "New Subject", template: "Hello!"}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["absoluteDelay"]).to eq("blank") }
          it { expect(MailyHerald::SequenceMailing.count).to eq(0) }
        end
      end
    end
  end

end

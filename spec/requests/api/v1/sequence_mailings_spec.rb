require "rails_helper"

describe "SequenceMailings API" do

  describe "POST #create" do
    let!(:sequence) { create :clean_sequence }

    it { expect(MailyHerald::Sequence.count).to eq(1) }
    it { expect(MailyHerald::SequenceMailing.count).to eq(0) }

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

  describe "GET #show" do
    let!(:sequence) { create :newsletters }
    let!(:mailing) { sequence.mailings.first }

    it { expect(MailyHerald::Sequence.count).to eq(1) }
    it { expect(MailyHerald::SequenceMailing.count).to eq(3) }

    context "with incorrect Sequence ID" do
      before { send_request :get, "/maily_herald/api/v1/sequences/0/mailings/#{mailing.id}" }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
    end

    context "with correct Sequence ID" do
      context "with incorrect SequenceMailing ID" do
        before { send_request :get, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings/0" }

        it { expect(response.status).to eq(404) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["error"]).to eq("notFound") }
      end

      context "with correct SequenceMailing ID" do
        before { send_request :get, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings/#{mailing.id}" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["sequenceMailing"]).to eq(
              {
                "id"                   =>  mailing.id,
                "sequenceId"           =>  sequence.id,
                "name"                 =>  mailing.name,
                "title"                =>  mailing.title,
                "subject"              =>  mailing.subject,
                "template"             =>  mailing.template,
                "conditions"           =>  mailing.conditions,
                "from"                 =>  mailing.from,
                "state"                =>  mailing.state.to_s,
                "mailerName"           =>  mailing.mailer_name.to_s,
                "locked"               =>  mailing.locked?,
                "absoluteDelayInDays"  =>  mailing.absolute_delay_in_days
             }
           )
          }
      end
    end
  end

  describe "PUT #update" do
    let!(:sequence) { create :newsletters }
    let!(:mailing) { sequence.mailings.first }

    it { expect(MailyHerald::Sequence.count).to eq(1) }
    it { expect(MailyHerald::SequenceMailing.count).to eq(3) }

    context "with incorrect Sequence ID" do
      before { send_request :put, "/maily_herald/api/v1/sequences/0/mailings/#{mailing.id}", {sequence_mailing: {subject: "New Subject"}}.to_json }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
    end

    context "with correct Sequence ID" do
      context "with incorrect SequenceMailing ID" do
        before { send_request :put, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings/0", {sequence_mailing: {subject: "New Subject"}}.to_json }

        it { expect(response.status).to eq(404) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["error"]).to eq("notFound") }
      end

      context "with correct SequenceMailing ID" do
        context "with correct params" do
          before { send_request :put, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings/#{mailing.id}", {sequence_mailing: {subject: "New Subject", template: "New Template", conditions: "active", state: "enabled", absolute_delay_in_days: 10}}.to_json }

          it { expect(response.status).to eq(200) }
          it { expect(response).to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["sequenceMailing"]["subject"]).to eq("New Subject") }
          it { expect(response_json["sequenceMailing"]["template"]).to eq("New Template") }
          it { expect(response_json["sequenceMailing"]["state"]).to eq("enabled") }
          it { expect(response_json["sequenceMailing"]["conditions"]).to eq("active") }
          it { expect(response_json["sequenceMailing"]["absoluteDelayInDays"]).to eq("10.00") }
          it { mailing.reload; expect(mailing.subject).to eq("New Subject") }
        end

        context "with incorrect params" do
          context "blanks" do
            before { send_request :put, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings/#{mailing.id}", {sequence_mailing: {title: "", subject: "", template: ""}}.to_json }

            it { expect(response.status).to eq(422) }
            it { expect(response).not_to be_success }
            it { expect(response_json).not_to be_empty }
            it { expect(response_json["errors"]["title"]).to eq("blank") }
            it { expect(response_json["errors"]["subject"]).to eq("blank") }
            it { expect(response_json["errors"]["template"]).to eq("blank") }
          end

          context "not setup mailer" do
            before { send_request :put, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings/#{mailing.id}", {sequence_mailing: {mailer_name: "wrongOne"}}.to_json }

            it { expect(response.status).to eq(422) }
            it { expect(response).not_to be_success }
            it { expect(response_json).not_to be_empty }
            it { expect(response_json["errors"]["mailerName"]).to eq("invalid") }
          end

          context "wrong conditions" do
            before { send_request :put, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings/#{mailing.id}", {sequence_mailing: {conditions: "{{"}}.to_json }

            it { expect(response.status).to eq(422) }
            it { expect(response).not_to be_success }
            it { expect(response_json).not_to be_empty }
            it { expect(response_json["errors"]["conditions"]).to eq("notBoolean") }
          end

          context "wrong template" do
            before { send_request :put, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings/#{mailing.id}", {sequence_mailing: {template: "{{"}}.to_json }

            it { expect(response.status).to eq(422) }
            it { expect(response).not_to be_success }
            it { expect(response_json).not_to be_empty }
            it { expect(response_json["errors"]["template"]).to eq("syntaxError") }
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:sequence) { create :newsletters }
    let!(:mailing) { sequence.mailings.first }

    it { expect(MailyHerald::Sequence.count).to eq(1) }
    it { expect(MailyHerald::SequenceMailing.count).to eq(3) }

    context "with incorrect Sequence ID" do
      before { send_request :delete, "/maily_herald/api/v1/sequences/0/mailings/#{mailing.id}" }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
      it { mailing.reload; expect(mailing.state.to_s).to eq("enabled") }
      it { expect(MailyHerald::SequenceMailing.count).to eq(3) }
    end

    context "with correct Sequence ID" do
      context "with correct SequenceMailing ID" do
        before { send_request :delete, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings/#{mailing.id}" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["sequenceMailing"]["state"]).to eq("archived") }
        it { mailing.reload; expect(mailing.state.to_s).to eq("archived") }
        it { expect(MailyHerald::SequenceMailing.count).to eq(3) }
      end

      context "with incorrect SequenceMailing ID" do
        before { send_request :delete, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings/0" }

        it { expect(response.status).to eq(404) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["error"]).to eq("notFound") }
        it { mailing.reload; expect(mailing.state.to_s).to eq("enabled") }
        it { expect(MailyHerald::SequenceMailing.count).to eq(3) }
      end
    end
  end

end

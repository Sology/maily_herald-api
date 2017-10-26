require "rails_helper"

describe "SequenceMailings API" do

  describe "GET #index" do
    let!(:sequence) { create :newsletters }
    let!(:mailing1) { sequence.mailings.first }
    let!(:mailing2) { sequence.mailings.second }

    it { expect(MailyHerald::Sequence.count).to eq(1) }
    it { expect(MailyHerald::SequenceMailing.count).to eq(3) }
    it { expect(mailing1).not_to be_nil }
    it { expect(mailing2).not_to be_nil }

    context "with incorrect Sequence ID" do
      before { send_request :get, "/maily_herald/api/v1/sequences/0/mailings" }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
    end

    context "with correct Sequence ID" do
      context "without any params" do
        before { send_request :get, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["sequenceMailings"].count).to eq(3) }
        it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
        it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
      end

      context "with defined per param" do
        before { send_request :get, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings", {per: 1} }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["sequenceMailings"].count).to eq(1) }
        it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
        it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_truthy }
      end

      context "with defined per and page param" do
        before { send_request :get, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings", {per: 1, page: 3} }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["sequenceMailings"].count).to eq(1) }
        it { expect(response_json["meta"]["pagination"]["page"]).to eq(3) }
        it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
      end

      context "with too high page param" do
        before { send_request :get, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings", {per: 1, page: 10} }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["sequenceMailings"].count).to eq(0) }
        it { expect(response_json["meta"]["pagination"]["page"]).to eq(10) }
        it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
      end

      context "with defined query param" do
        before { send_request :get, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings", {query: query} }

        context "when query is 'ini'" do
          let(:query) { "ini" }

          it { expect(response.status).to eq(200) }
          it { expect(response).to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["sequenceMailings"].count).to eq(1) }
          it { expect(response_json["sequenceMailings"].first["name"]).to eq(mailing1.name) }
          it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
          it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
        end

        context "when query is 'sec'" do
          let(:query) { "sec" }

          it { expect(response.status).to eq(200) }
          it { expect(response).to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["sequenceMailings"].count).to eq(1) }
          it { expect(response_json["sequenceMailings"].first["name"]).to eq(mailing2.name) }
          it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
          it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
        end
      end

      context "with 'state' param" do
        context "when 'enabled' or 'disabled'" do
          before do
            mailing1.disable!
            mailing1.reload
            expect(MailyHerald::SequenceMailing.enabled.count).to eq(2)
          end

          context "should return enabled sequence mailings" do
            before { send_request :get, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings", {state: :enabled} }

            it { expect(response.status).to eq(200) }
            it { expect(response).to be_success }
            it { expect(response_json).not_to be_empty }
            it { expect(response_json["sequenceMailings"].count).to eq(2) }
            it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
            it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
          end

          context "should return disabled sequence mailings'" do
            before { send_request :get, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings", {state: :disabled} }

            it { expect(response.status).to eq(200) }
            it { expect(response).to be_success }
            it { expect(response_json).not_to be_empty }
            it { expect(response_json["sequenceMailings"].count).to eq(1) }
            it { expect(response_json["sequenceMailings"].first["state"]).to eq("disabled") }
            it { expect(response_json["sequenceMailings"].first["name"]).to eq(mailing1.name) }
            it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
            it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
          end
        end

        context "when 'archived' or 'not_archived'" do
          before do
            mailing1.archive!
            mailing1.reload
            expect(MailyHerald::SequenceMailing.archived.count).to eq(1)
          end

          context "should return archived sequence mailings" do
            before { send_request :get, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings", {state: :archived} }

            it { expect(response.status).to eq(200) }
            it { expect(response).to be_success }
            it { expect(response_json).not_to be_empty }
            it { expect(response_json["sequenceMailings"].count).to eq(1) }
            it { expect(response_json["sequenceMailings"].first["state"]).to eq("archived") }
            it { expect(response_json["sequenceMailings"].first["name"]).to eq(mailing1.name) }
            it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
            it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
          end

          context "should return enabled and disabled sequence mailings" do
            before { send_request :get, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings", {state: :not_archived} }

            it { expect(response.status).to eq(200) }
            it { expect(response).to be_success }
            it { expect(response_json).not_to be_empty }
            it { expect(response_json["sequenceMailings"].count).to eq(2) }
            it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
            it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
          end
        end
      end

      context "'query' and 'state' combined" do
        before { send_request :get, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings", {state: :enabled, query: "init"} }

        it { expect(MailyHerald::SequenceMailing.enabled.count).to eq(3) }
        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["sequenceMailings"].count).to eq(1) }
        it { expect(response_json["sequenceMailings"].first["name"]).to eq(mailing1.name) }
        it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
        it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
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

        context "nil subject when generic mailer" do
          before { send_request :post, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings", {sequence_mailing: {title: "New sequenceMailing", template: "Hello!", absolute_delay_in_days: 0.04}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["subject"]).to eq("blank") }
          it { expect(MailyHerald::SequenceMailing.count).to eq(0) }
        end

        context "nil template when generic mailer" do
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

  describe "GET #preview" do
    let!(:sequence) { create :newsletters }
    let!(:mailing) { sequence.mailings.first }
    let!(:entity) { create :user }

    before do
      mailing.list.subscribe! entity
      mailing.reload
    end

    it { expect(MailyHerald::Sequence.count).to eq(1) }
    it { expect(MailyHerald::SequenceMailing.count).to eq(3) }
    it { expect(mailing.list.active_subscription_count).to eq(1) }

    context "with incorrect Sequence ID" do
      before { send_request :get, "/maily_herald/api/v1/sequences/0/mailings/#{mailing.id}/preview/#{entity.id}" }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
    end

    context "with correct Sequence ID" do
      context "with incorrect SequenceMailing ID" do
        before { send_request :get, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings/0/preview/#{entity.id}" }

        it { expect(response.status).to eq(404) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["error"]).to eq("notFound") }
      end

      context "with correct SequenceMailing ID" do
        context "with incorrect entity ID" do
          before { send_request :get, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings/#{mailing.id}/preview/0" }

          it { expect(response.status).to eq(404) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["error"]).to eq("notFound") }
        end

        context "with correct entity ID" do
          before { send_request :get, "/maily_herald/api/v1/sequences/#{sequence.id}/mailings/#{mailing.id}/preview/#{entity.id}" }

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
  end

end

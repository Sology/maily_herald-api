require "rails_helper"

describe "Sequences API" do

  describe "GET #index" do
    let!(:sequence1) { create :clean_sequence }
    let!(:sequence2) { create :newsletters }

    context "without any params" do
      before { send_request :get, "/maily_herald/api/v1/sequences" }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["sequences"].count).to eq(2) }
      it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
      it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
    end

    context "with defined per param" do
      before { send_request :get, "/maily_herald/api/v1/sequences", {per: 1} }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["sequences"].count).to eq(1) }
      it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
      it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_truthy }
    end

    context "with defined per and page param" do
      before { send_request :get, "/maily_herald/api/v1/sequences", {per: 1, page: 2} }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["sequences"].count).to eq(1) }
      it { expect(response_json["meta"]["pagination"]["page"]).to eq(2) }
      it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
    end

    context "with too high page param" do
      before { send_request :get, "/maily_herald/api/v1/sequences", {per: 1, page: 10} }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["sequences"].count).to eq(0) }
      it { expect(response_json["meta"]["pagination"]["page"]).to eq(10) }
      it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
    end

    context "with defined query param" do
      before { send_request :get, "/maily_herald/api/v1/sequences", {query: query} }

      context "when query is 'cle'" do
        let(:query) { "cle" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["sequences"].count).to eq(1) }
        it { expect(response_json["sequences"].first["name"]).to eq("clean_sequence") }
        it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
        it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
      end

      context "when query is 'news'" do
        let(:query) { "news" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["sequences"].count).to eq(1) }
        it { expect(response_json["sequences"].first["name"]).to eq("newsletters") }
        it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
        it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
      end
    end

    context "with 'state' param" do
      context "when 'enabled' or 'disabled'" do
        before do
          sequence1.disable!
          sequence1.reload
          expect(MailyHerald::Sequence.enabled.count).to eq(1)
        end

        context "should return enabled sequences" do
          before { send_request :get, "/maily_herald/api/v1/sequences", {state: :enabled} }

          it { expect(response.status).to eq(200) }
          it { expect(response).to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["sequences"].count).to eq(1) }
          it { expect(response_json["sequences"].first["state"]).to eq("enabled") }
          it { expect(response_json["sequences"].first["name"]).to eq(sequence2.name) }
          it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
          it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
        end

        context "should return disabled sequences'" do
          before { send_request :get, "/maily_herald/api/v1/sequences", {state: :disabled} }

          it { expect(response.status).to eq(200) }
          it { expect(response).to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["sequences"].count).to eq(1) }
          it { expect(response_json["sequences"].first["state"]).to eq("disabled") }
          it { expect(response_json["sequences"].first["name"]).to eq(sequence1.name) }
          it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
          it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
        end
      end

      context "when 'archived' or 'not_archived'" do
        before do
          sequence1.archive!
          sequence1.reload
          expect(MailyHerald::Sequence.archived.count).to eq(1)
        end

        context "should return archived sequences" do
          before { send_request :get, "/maily_herald/api/v1/sequences", {state: :archived} }

          it { expect(response.status).to eq(200) }
          it { expect(response).to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["sequences"].count).to eq(1) }
          it { expect(response_json["sequences"].first["state"]).to eq("archived") }
          it { expect(response_json["sequences"].first["name"]).to eq(sequence1.name) }
          it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
          it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
        end

        context "should return enabled and disabled sequences" do
          before { send_request :get, "/maily_herald/api/v1/sequences", {state: :not_archived} }

          it { expect(response.status).to eq(200) }
          it { expect(response).to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["sequences"].count).to eq(1) }
          it { expect(response_json["sequences"].first["state"]).to eq("enabled") }
          it { expect(response_json["sequences"].first["name"]).to eq(sequence2.name) }
          it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
          it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
        end
      end
    end

    context "'query' and 'state' combined" do
      before { send_request :get, "/maily_herald/api/v1/sequences", {state: :enabled, query: "clean"} }

      it { expect(MailyHerald::Sequence.enabled.count).to eq(2) }
      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["sequences"].count).to eq(1) }
      it { expect(response_json["sequences"].first["name"]).to eq(sequence1.name) }
      it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
      it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
    end
  end

  describe "GET #show" do
    context "without sequence mailings" do
      let!(:sequence) { create :clean_sequence }

      it { expect(MailyHerald::Sequence.count).to eq(1) }
      it { expect(sequence.mailings.count).to eq(0) }

      context "with incorrect Sequence ID" do
        before { send_request :get, "/maily_herald/api/v1/sequences/0" }

        it { expect(response.status).to eq(404) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["error"]).to eq("notFound") }
      end

      context "with correct Sequence ID" do
        before { send_request :get, "/maily_herald/api/v1/sequences/#{sequence.id}" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["sequence"]).to eq(
              {
                "id"                =>  sequence.id,
                "listId"            =>  sequence.list.id,
                "name"              =>  sequence.name,
                "title"             =>  sequence.title,
                "state"             =>  sequence.state.to_s,
                "startAt"           =>  sequence.start_at.as_json,
                "locked"            =>  false,
                "sequenceMailings"  =>  []
             }
           )
          }
      end
    end

    context "with sequence mailings" do
      let!(:sequence) { create :newsletters }
      let!(:mailing1) { sequence.mailings.where(name: "initial_mail").first }
      let!(:mailing2) { sequence.mailings.where(name: "second_mail").first }
      let!(:mailing3) { sequence.mailings.where(name: "third_mail").first }

      context "setup" do
        it { expect(MailyHerald::Sequence.count).to eq(1) }
        it { expect(MailyHerald::SequenceMailing.count).to eq(3) }
        it { expect(sequence.mailings.count).to eq(3) }
        it { expect(mailing1).not_to be_nil }
        it { expect(mailing2).not_to be_nil }
        it { expect(mailing3).not_to be_nil }
      end

      context "with correct Sequence ID" do
        before { send_request :get, "/maily_herald/api/v1/sequences/#{sequence.id}" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["sequence"]).to eq(
              {
                "id"                =>  sequence.id,
                "listId"            =>  sequence.list.id,
                "name"              =>  sequence.name,
                "title"             =>  sequence.title,
                "state"             =>  sequence.state.to_s,
                "startAt"           =>  sequence.start_at.as_json,
                "locked"            =>  false,
                "sequenceMailings"  =>  [
                                          {
                                            "id"                   =>  mailing1.id,
                                            "sequenceId"           =>  sequence.id,
                                            "name"                 =>  mailing1.name,
                                            "title"                =>  mailing1.title,
                                            "subject"              =>  mailing1.subject,
                                            "template"             =>  mailing1.template,
                                            "conditions"           =>  mailing1.conditions,
                                            "from"                 =>  mailing1.from,
                                            "state"                =>  mailing1.state.to_s,
                                            "mailerName"           =>  mailing1.mailer_name.to_s,
                                            "locked"               =>  false,
                                            "absoluteDelay"        =>  mailing1.absolute_delay
                                          },
                                          {
                                            "id"                   =>  mailing2.id,
                                            "sequenceId"           =>  sequence.id,
                                            "name"                 =>  mailing2.name,
                                            "title"                =>  mailing2.title,
                                            "subject"              =>  mailing2.subject,
                                            "template"             =>  mailing2.template,
                                            "conditions"           =>  mailing2.conditions,
                                            "from"                 =>  mailing2.from,
                                            "state"                =>  mailing2.state.to_s,
                                            "mailerName"           =>  mailing2.mailer_name.to_s,
                                            "locked"               =>  false,
                                            "absoluteDelay"        =>  mailing2.absolute_delay
                                          },
                                          {
                                            "id"                   =>  mailing3.id,
                                            "sequenceId"           =>  sequence.id,
                                            "name"                 =>  mailing3.name,
                                            "title"                =>  mailing3.title,
                                            "subject"              =>  mailing3.subject,
                                            "template"             =>  mailing3.template,
                                            "conditions"           =>  mailing3.conditions,
                                            "from"                 =>  mailing3.from,
                                            "state"                =>  mailing3.state.to_s,
                                            "mailerName"           =>  mailing3.mailer_name.to_s,
                                            "locked"               =>  false,
                                            "absoluteDelay"        =>  mailing3.absolute_delay
                                          }
                                        ]
             }
           )
          }
      end
    end
  end

  describe "POST #create" do
    let(:list)     { MailyHerald.list :generic_list }
    let(:start_at) { Time.now + 1.minute }

    it { expect(MailyHerald::Sequence.count).to eq(0) }

    context "with correct params" do
      before { send_request :post, "/maily_herald/api/v1/sequences", {sequence: {title: "New Sequence", list: "generic_list", start_at: start_at}}.to_json }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(MailyHerald::Sequence.count).to eq(1) }
      it { expect(response_json["sequence"]["id"]).to eq(MailyHerald::Sequence.where(name: "new_sequence").first.id) }
      it { expect(response_json["sequence"]["listId"]).to eq(list.id) }
      it { expect(response_json["sequence"]["name"]).to eq("new_sequence") }
      it { expect(response_json["sequence"]["title"]).to eq("New Sequence") }
      it { expect(response_json["sequence"]["state"]).to eq("disabled") }
      it { expect(response_json["sequence"]["startAt"]).to eq(start_at.as_json) }
      it { expect(response_json["sequence"]["locked"]).to be_falsy }
      it { expect(response_json["sequence"]["sequenceMailings"]).to be_kind_of(Array) }
      it { expect(response_json["sequence"]["sequenceMailings"]).to be_empty }
    end

    context "with incorrect params" do
      context "nil title" do
        before { send_request :post, "/maily_herald/api/v1/sequences", {sequence: {list: "generic_list", start_at: start_at}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["name"]).to eq("blank") }
        it { expect(response_json["errors"]["title"]).to eq("blank") }
        it { expect(MailyHerald::Sequence.count).to eq(0) }
      end

      context "nil list" do
        before { send_request :post, "/maily_herald/api/v1/sequences", {sequence: {title: "New Sequence", start_at: start_at}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["list"]).to eq("blank") }
        it { expect(MailyHerald::Sequence.count).to eq(0) }
      end

      context "wrong list" do
        before { send_request :post, "/maily_herald/api/v1/sequences", {sequence: {title: "New Sequence", list: "wrongOne", start_at: start_at}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["list"]).to eq("blank") }
        it { expect(MailyHerald::Sequence.count).to eq(0) }
      end

      context "nil start_at" do
        before { send_request :post, "/maily_herald/api/v1/sequences", {sequence: {title: "New Sequence", list: "generic_list"}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["startAt"]).to eq("blank") }
        it { expect(MailyHerald::Sequence.count).to eq(0) }
      end

      context "wrong start_at" do
        before { send_request :post, "/maily_herald/api/v1/sequences", {sequence: {title: "New Sequence", list: "generic_list", start_at: "{{"}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["startAt"]).to eq("notTime") }
        it { expect(MailyHerald::Sequence.count).to eq(0) }
      end
    end
  end

  describe "PUT #update" do
    let!(:sequence) { create :clean_sequence }
    let(:start_at)  { "user.created_at + 5.minutes" }

    it { expect(MailyHerald::Sequence.count).to eq(1) }

    context "with incorrect Sequence ID" do
      before { send_request :put, "/maily_herald/api/v1/sequences/0", {sequence: {title: "New Title", state: "enabled", start_at: start_at}}.to_json }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
    end

    context "with correct Sequence ID" do
      context "with correct params" do
        before { send_request :put, "/maily_herald/api/v1/sequences/#{sequence.id}", {sequence: {title: "New Title", state: "enabled", start_at: start_at}}.to_json }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["sequence"]["title"]).to eq("New Title") }
        it { expect(response_json["sequence"]["state"]).to eq("enabled") }
        it { expect(response_json["sequence"]["startAt"]).to eq(start_at) }
        it { sequence.reload; expect(sequence.title).to eq("New Title") }
      end

      context "with incorrect params" do
        context "blanks" do
          before { send_request :put, "/maily_herald/api/v1/sequences/#{sequence.id}", {sequence: {title: "", list: "", start_at: ""}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["title"]).to eq("blank") }
          it { expect(response_json["errors"]["list"]).to eq("blank") }
          it { expect(response_json["errors"]["startAt"]).to eq("blank") }
        end

        context "wrong start_at" do
          before { send_request :put, "/maily_herald/api/v1/sequences/#{sequence.id}", {sequence: {start_at: "{{"}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["startAt"]).to eq("notTime") }
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:sequence) { create :clean_sequence }

    it { expect(MailyHerald::Sequence.count).to eq(1) }

    context "with correct Sequence ID" do
      before { send_request :delete, "/maily_herald/api/v1/sequences/#{sequence.id}" }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["sequence"]["state"]).to eq("archived") }
      it { expect(MailyHerald::Sequence.count).to eq(1) }
    end

    context "with incorrect Sequence ID" do
      before { send_request :delete, "/maily_herald/api/v1/sequences/0" }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
      it { sequence.reload; expect(sequence.state.to_s).to eq("enabled") }
      it { expect(MailyHerald::Sequence.count).to eq(1) }
    end
  end

end

require "rails_helper"

describe "Logs API" do

  describe "GET #index" do
    let!(:mailing)        { create :weekly_summary }
    let!(:second_mailing) { create :generic_one_time_mailing }
    let!(:entity)         { create :user, email: "first@example.com" }
    let!(:second_entity)  { create :user, email: "second@example.com" }

    let!(:scheduled_log)  { MailyHerald::Log.create_for mailing, entity, {status: :scheduled} }
    let!(:delivered_log)  { MailyHerald::Log.create_for mailing, entity, {status: :delivered} }
    let!(:skipped_log)    { MailyHerald::Log.create_for mailing, entity, {status: :skipped} }
    let!(:error_log)      { MailyHerald::Log.create_for mailing, entity, {status: :error} }

    let!(:skipped_log_se) { MailyHerald::Log.create_for second_mailing, second_entity, {status: :skipped} }

    it { expect(MailyHerald::Log.count).to eq(5) }

    context "without any params" do
      before { send_request :get, "/maily_herald/api/v1/logs" }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["logs"].count).to eq(5) }
      it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
      it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
    end

    context "with pagination params" do
      context "with defined per param" do
        before { send_request :get, "/maily_herald/api/v1/logs", {per: 1} }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["logs"].count).to eq(1) }
        it { expect(response_json["meta"]["pagination"]["page"]).to eq(1) }
        it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_truthy }
      end

      context "with defined per and page param" do
        before { send_request :get, "/maily_herald/api/v1/logs", {per: 1, page: 5} }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["logs"].count).to eq(1) }
        it { expect(response_json["meta"]["pagination"]["page"]).to eq(5) }
        it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
      end

      context "with too high page param" do
        before { send_request :get, "/maily_herald/api/v1/logs", {per: 1, page: 10} }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["logs"].count).to eq(0) }
        it { expect(response_json["meta"]["pagination"]["page"]).to eq(10) }
        it { expect(response_json["meta"]["pagination"]["nextPage"]).to be_falsy }
      end
    end

    context "with query param" do
      before { send_request :get, "/maily_herald/api/v1/logs", {query: query} }

      context "when query is 'fir'" do
        let(:query) { "fir" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["logs"].count).to eq(4) }
      end

      context "when query is 'sec'" do
        let(:query) { "sec" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["logs"].count).to eq(1) }
        it { expect(response_json["logs"].first["entityId"]).to eq(second_entity.id) }
      end
    end

    context "with status param" do
      before { send_request :get, "/maily_herald/api/v1/logs", {status: status} }

      context "scheduled" do
        let(:status) { "scheduled" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["logs"].count).to eq(1) }
        it { expect(response_json["logs"].first["id"]).to eq(scheduled_log.id) }
      end

      context "delivered" do
        let(:status) { "delivered" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["logs"].count).to eq(1) }
        it { expect(response_json["logs"].first["id"]).to eq(delivered_log.id) }
      end

      context "skipped" do
        let(:status) { "skipped" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["logs"].count).to eq(2) }
        it { expect(response_json["logs"].first["id"]).to eq(skipped_log.id) }
        it { expect(response_json["logs"].second["id"]).to eq(skipped_log_se.id) }
      end

      context "not_skipped" do
        let(:status) { "not_skipped" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["logs"].count).to eq(3) }
      end

      context "error" do
        let(:status) { "error" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["logs"].count).to eq(1) }
        it { expect(response_json["logs"].first["id"]).to eq(error_log.id) }
      end

      context "processed" do
        let(:status) { "processed" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["logs"].count).to eq(4) }
      end

      context "any other string" do
        let(:status) { "wrongStatus" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["logs"].count).to eq(5) }
      end
    end

    context "with mailing_id param" do
      before { send_request :get, "/maily_herald/api/v1/logs", {mailing_id: mailing_id} }

      context "when correct" do
        let(:mailing_id) { second_mailing.id }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["logs"].count).to eq(1) }
        it { expect(response_json["logs"].first["id"]).to eq(skipped_log_se.id) }
      end

      context "when incorrect" do
        let(:mailing_id) { 0 }

        it { expect(response.status).to eq(404) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["error"]).to eq("notFound") }
      end
    end

    context "with entity_type and entity_id params" do
      context "correct params" do
        context "with entity_type only" do
          before { send_request :get, "/maily_herald/api/v1/logs", {entity_type: "user"} }

          it { expect(response.status).to eq(200) }
          it { expect(response).to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["logs"].count).to eq(5) }
        end

        context "with entity_id only" do
          before { send_request :get, "/maily_herald/api/v1/logs", {entity_id: second_entity.id} }

          it { expect(response.status).to eq(200) }
          it { expect(response).to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["logs"].count).to eq(5) }
        end

        context "with entity_type and entity_id" do
          before { send_request :get, "/maily_herald/api/v1/logs", {entity_type: "user", entity_id: second_entity.id} }

          it { expect(response.status).to eq(200) }
          it { expect(response).to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["logs"].count).to eq(1) }
          it { expect(response_json["logs"].first["id"]).to eq(skipped_log_se.id) }
        end
      end

      context "incorrect params" do
        context "with wrong entity_type, but right entity_id" do
          before { send_request :get, "/maily_herald/api/v1/logs", {entity_type: "wrongOne", entity_id: second_entity.id} }

          it { expect(response.status).to eq(404) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["error"]).to eq("notFound") }
        end

        context "with wrong entity_id, but right entity_type" do
          before { send_request :get, "/maily_herald/api/v1/logs", {entity_type: "user", entity_id: 0} }

          it { expect(response.status).to eq(404) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["error"]).to eq("notFound") }
        end

        context "with both wrong" do
          before { send_request :get, "/maily_herald/api/v1/logs", {entity_type: "wrongOne", entity_id: 0} }

          it { expect(response.status).to eq(404) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["error"]).to eq("notFound") }
        end
      end
    end

    context "all params combined" do
      before { send_request :get, "/maily_herald/api/v1/logs", {entity_type: "user", entity_id: entity.id, mailing_id: mailing.id, status: "error"} }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["logs"].count).to eq(1) }
      it { expect(response_json["logs"].first["id"]).to eq(error_log.id) }
    end
  end

end

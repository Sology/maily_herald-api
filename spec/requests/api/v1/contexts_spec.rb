require "rails_helper"

describe "Contexts API" do

  describe "GET #index" do
    before { send_request :get, "/maily_herald/api/v1/contexts" }

    it { expect(response.status).to eq(200) }
    it { expect(response).to be_success }
    it { expect(response_json).not_to be_empty }
    it { expect(response_json["contexts"].count).to eq(1) }
    it { expect(response_json["contexts"].first["name"]).to eq("all_users") }
    it { expect(response_json["contexts"].first["title"]).to be_nil }
    it { expect(response_json["contexts"].first["modelName"]).to eq("User") }
    it { expect(response_json["contexts"].first["attributes"]).to eq(["name", "email", "created_at", "weekly_notifications", "properties", "prop1", "prop2"]) }
  end

  describe "GET #show" do
    context "with valid context name" do
      before { send_request :get, "/maily_herald/api/v1/contexts/all_users" }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["context"]["name"]).to eq("all_users") }
      it { expect(response_json["context"]["title"]).to be_nil }
      it { expect(response_json["context"]["modelName"]).to eq("User") }
      it { expect(response_json["context"]["attributes"]).to eq(["name", "email", "created_at", "weekly_notifications", "properties", "prop1", "prop2"]) }
    end

    context "with invalid context name" do
      before { send_request :get, "/maily_herald/api/v1/contexts/wrongOne" }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
    end
  end

end

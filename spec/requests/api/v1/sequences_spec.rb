require "rails_helper"

describe "Sequences API" do

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

end

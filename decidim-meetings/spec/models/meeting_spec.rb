# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Meeting do
    subject { meeting }

    let(:address) { Faker::Lorem.sentence(3) }
    let(:meeting) { build :meeting, address: address }

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }

    include_examples "has component"
    include_examples "has scope"
    include_examples "has category"
    include_examples "has reference"

    context "without a title" do
      let(:meeting) { build :meeting, title: nil }

      it { is_expected.not_to be_valid }
    end

    context "when geocoding is enabled" do
      let(:address) { "Carrer del Pare Llaurador, 113" }
      let(:latitude) { 40.1234 }
      let(:longitude) { 2.1234 }

      before do
        Geocoder::Lookup::Test.add_stub(
          address,
          [{
            "latitude" => latitude,
            "longitude" => longitude
          }]
        )
      end

      it "geocodes address and find latitude and longitude" do
        subject.geocode
        expect(subject.latitude).to eq(latitude)
        expect(subject.longitude).to eq(longitude)
      end
    end

    describe "#users_to_notify_on_comment_created" do
      let!(:follows) { create_list(:follow, 3, followable: subject) }

      it "returns the followers" do
        expect(subject.users_to_notify_on_comment_created).to match_array(follows.map(&:user))
      end
    end

    describe "#can_be_joined_by?" do
      subject { meeting.can_be_joined_by?(user) }

      let(:user) { build :user, organization: meeting.component.organization }

      context "when registrations are disabled" do
        let(:meeting) { build :meeting, registrations_enabled: false }

        it { is_expected.to eq false }
      end

      context "when meeting is closed" do
        let(:meeting) { build :meeting, :closed }

        it { is_expected.to eq false }
      end

      context "when the user cannot participate to the meeting" do
        let(:meeting) { build :meeting, :closed }

        before do
          allow(meeting).to receive(:can_participate?).and_return(false)
        end

        it { is_expected.to eq false }
      end

      context "when everything is OK" do
        let(:meeting) { build :meeting, registrations_enabled: true }

        it { is_expected.to eq true }
      end
    end
  end
end

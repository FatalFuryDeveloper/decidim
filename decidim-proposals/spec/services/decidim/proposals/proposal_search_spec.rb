require "spec_helper"

module Decidim
  module Proposals
    describe ProposalSearch do
      let(:feature) { create(:feature, manifest_name: "proposals") }
      let(:user) { create(:user, organization: feature.organization) }
      let!(:proposal) { create(:proposal, feature: feature)}

      describe "results" do
        let(:activity) { [] }
        let(:search_text) { nil }
        let(:origin) { nil }
        let(:state) { nil }

        subject do
          described_class.new({
            feature: feature,
            activity: activity,
            search_text: search_text,
            state: state,
            origin: origin,
            current_user: user
          }).results
        end

        it "only includes proposals from the given feature" do
          other_proposal = create(:proposal)

          expect(subject).to include(proposal)
          expect(subject).not_to include(other_proposal)
        end

        describe "when the filter includes search_text" do
          let(:search_text) { "dog" }

          it "returns the proposals containing the search in the title or the body" do
            create_list(:proposal, 3, feature: feature)
            create(:proposal, title: "A dog", feature: feature)
            create(:proposal, body: "There is a dog in the office", feature: feature)

            expect(subject.size).to eq(2)
          end
        end

        describe "when the filter includes activity" do
          let(:activity) { ["voted"] }

          it "returns the proposals voted by the user" do
            create_list(:proposal, 3, feature: feature)
            create(:proposal_vote, proposal: Proposal.first, author: user)

            expect(subject.size).to eq(1)
          end
        end

        describe "when the filter includes origin" do
          context "when filtering official proposals" do
            let(:origin) { "official" }

            it "returns only official proposals" do
              official_proposals = create_list(:proposal, 3, :official, feature: feature)
              create_list(:proposal, 3, feature: feature)

              expect(subject.size).to eq(3)
              expect(subject).to match_array(official_proposals)
            end
          end

          context "when filtering citizen proposals" do
            let(:origin) { "citizenship" }

            it "returns only citizen proposals" do
              create_list(:proposal, 3, :official, feature: feature)
              citizen_proposals = create_list(:proposal, 2, feature: feature)
              citizen_proposals << proposal

              expect(subject.size).to eq(3)
              expect(subject).to match_array(citizen_proposals)
            end
          end
        end

        describe "when the filter includes state" do
          context "when filtering accpeted proposals" do
            let(:state) { "accepted" }

            it "returns only accepted proposals" do
              accepted_proposals = create_list(:proposal, 3, :accepted, feature: feature)
              create_list(:proposal, 3, feature: feature)

              expect(subject.size).to eq(3)
              expect(subject).to match_array(accepted_proposals)
            end
          end

          context "when filtering rejected proposals" do
            let(:state) { "rejected" }

            it "returns only rejected proposals" do
              create_list(:proposal, 3, feature: feature)
              rejected_proposals = create_list(:proposal, 3, :rejected, feature: feature)

              expect(subject.size).to eq(3)
              expect(subject).to match_array(rejected_proposals)
            end
          end
        end
      end
    end
  end
end

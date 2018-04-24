# frozen_string_literal: true

module Decidim
  module Meetings
    # The data store for a Meeting in the Decidim::Meetings component. It stores a
    # title, description and any other useful information to render a custom meeting.
    class Agenda < Meetings::ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable

      belongs_to :meeting, foreign_key: "decidim_meeting_id", class_name: "Decidim::Meetings::Meeting"
      has_many :agenda_items, foreign_key: "decidim_agenda_id", class_name: "Decidim::Meetings::AgendaItem", dependent: :destroy, inverse_of: :agenda

      # validates :title, presence: true

      def self.log_presenter_class_for(_log)
        Decidim::Meetings::AdminLog::AgendaPresenter
      end
    end
  end
end
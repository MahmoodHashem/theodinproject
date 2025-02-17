require 'rails_helper'

RSpec.describe Notifications::FlagSubmission do
  subject(:notification) { described_class.new(flag) }

  let(:flag) do
    create(
      :flag,
      id: 120,
      flagger:,
      project_submission: flagged_submission,
      reason: :inappropriate,
      extra: 'I find it offensive'
    )
  end

  let(:flagger) { create(:user, username: 'OdinUser') }
  let(:flagged_submission) { create(:project_submission) }

  describe '#message' do
    it 'returns the daily summary message' do
      notification_message = "OdinUser has flagged a submission on #{flagged_submission.lesson.title}\n" \
                             "Reason: inappropriate\n" \
                             "Extra: I find it offensive\n" \
                             'Resolve the flag here: http://localhost:3001/admin_v2/flags/120'

      expect(notification.message).to eq notification_message
    end
  end

  describe '#destination' do
    around do |example|
      Dotenv.modify(
        DISCORD_FLAGGED_SUBMISSIONS_CHANNEL: 'Flagged Submission Channel'
      ) do
        example.run
      end
    end

    it 'returns the notification destination' do
      expect(notification.destination).to eql('Flagged Submission Channel')
    end
  end
end

require 'rails_helper'

RSpec.describe 'Resend team member invite' do
  describe 'POST #create' do
    context 'when signed in as an admin and the team member is pending' do
      it 'sends another invitation email to the team member' do
        admin = create(:admin_user)
        pending_admin = create(:admin_user, :pending, email: 'pending@odin.com')
        sign_in(admin)

        expect do
          post admin_v2_team_member_resend_invitation_path(pending_admin)
        end.to change { ActionMailer::Base.deliveries.count }

        mailer = ActionMailer::Base.deliveries.last

        expect(mailer.to).to eq(['pending@odin.com'])
        expect(mailer.subject).to eq('Joining The Odin Project Admin Team')
      end
    end

    context 'when signed in as an admin and the team member is not pending' do
      it 'does not send the team member another invite' do
        admin = create(:admin_user)
        active_admin = create(:admin_user, :activated, email: 'active@odin.com')

        sign_in(admin)

        expect do
          post admin_v2_team_member_resend_invitation_path(active_admin)
        end.not_to change { ActionMailer::Base.deliveries.count }
      end
    end

    context "when signed in as an admin and the team member doesn't exist" do
      it 'does not send an invitation email' do
        admin = create(:admin_user)

        sign_in(admin)

        expect do
          post admin_v2_team_member_resend_invitation_path(team_member_id: 1007)
        end.not_to change { ActionMailer::Base.deliveries.count }

        expect(response).to redirect_to(admin_v2_team_path)
        expect(flash[:alert]).to eq('Team member not found')
      end
    end

    context 'when not signed in as an admin' do
      it 'redirects to the admin sign in page' do
        user = create(:user)
        admin = create(:admin_user)
        sign_in(user)

        expect do
          post admin_v2_team_member_resend_invitation_path(admin)
        end.not_to change { ActionMailer::Base.deliveries.count }

        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end
  end
end

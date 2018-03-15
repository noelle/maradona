require 'test_helper'

class SquadsMemberInvitationsFlowsTest < ActionDispatch::IntegrationTest
  test 'diego invites a new member to squad' do
    sign_in users(:diego)
    squad = squads(:fifa_100)
    get squad_path(squad)
    assert_response :success

    assert_select 'a.btn-primary', 'Invite friend to squad'

    get new_squad_member_invitation_path(squad)
    form_submit_button = css_select('form input[type=submit].btn-primary').first
    assert_select 'h1', "Invite friend to Fifa 100"
    assert_select 'a.btn-default', 'Cancel'
    assert_equal 'Invite friend', form_submit_button.attr('value')
    assert_select 'form #squad_member_invitation_nickname'

    post squad_member_invitations_path(squad), params: {
      squad_member_invitation: {
        nickname: 'pele'
      }
    }
    follow_redirect!
    assert_response :success

    assert_select '.squad_members .card-text', 'pele'
  end

  test 'pele accepts an invitation' do
    squad = squads(:les_bleues)
    sign_in users(:pele)
    get root_path

    assert_select 'nav span.badge.badge-success', '1', 'Pele should see an invitation'
    get squads_path
    assert_response :success

    assert_invitation_is_shown

    squads_card_count_before = css_select('.squads .card').count

    post squad_accept_invitations_path(squad)
    follow_redirect!
    assert_response :success

    assert_select 'h1', 'Squads'
    squads_card_count_after = css_select('.squads .card').count
    assert_equal squads_card_count_before + 1, squads_card_count_after, 'There should be one more (accepted) squads'
    assert_select '.squad_invitations .card', { count: 0 }, 'There should not be any invitions anymore'
  end

  test 'pele rejects an invitation' do
    squad = squads(:les_bleues)
    sign_in users(:pele)

    get squads_path
    assert_response :success

    assert_invitation_is_shown

    squads_card_count_before = css_select('.squads .card').count

    post squad_reject_invitations_path(squad)
    follow_redirect!
    assert_response :success

    assert_select 'h1', 'Squads'
    squads_card_count_after = css_select('.squads .card').count
    assert_select '.squad_invitations .card', { count: 0 }, 'There should not be any invitions anymore'
    assert_equal squads_card_count_before, squads_card_count_after, 'The number of (accepted) squads should not have changed'
  end

  private

  def assert_invitation_is_shown
    assert_select '.squad_invitations .card'
    assert_select '.squad_invitations .card .card-title', 'Les Bleues'
    accept_invitation_form_button = css_select('.squad_invitations .accept_invitation').first
    reject_invitation_form_button = css_select('.squad_invitations .reject_invitation').first
    assert_equal 'Accept', accept_invitation_form_button.attr('value')
    assert_equal 'Reject', reject_invitation_form_button.attr('value')
  end
end
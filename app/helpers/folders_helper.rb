# frozen_string_literal: true

module FoldersHelper
  def profile_color(profile_name)
    colors = [
      '#3B82F6', '#10B981', '#F59E0B', '#EF4444',
      '#8B5CF6', '#06B6D4', '#F97316', '#84CC16',
      '#EC4899', '#6366F1', '#14B8A6', '#F43F5E'
    ]
    
    index = profile_name.hash.abs % colors.length
    colors[index]
  end

  def user_profile_permissions(user, profile)
    user_profile = user.user_profiles.find_by(profile: profile)
    return nil unless user_profile
    
    {
      can_create: user_profile.can_create,
      can_read: user_profile.can_read,
      can_update: user_profile.can_update,
      can_delete: user_profile.can_delete
    }
  end

  def accessible_profiles_for_user(user)
    if user.admin?
      Profile.all
    else
      Profile.joins(:user_profiles)
        .where(user_profiles: { user: user, can_read: true })
        .distinct
    end
  end

  def profile_summary_for_user(user)
    accessible_profiles = accessible_profiles_for_user(user)
    
    {
      total_profiles: accessible_profiles.count,
      can_create_any: accessible_profiles.joins(:user_profiles)
        .where(user_profiles: { user: user, can_create: true }).exists?,
      can_update_any: accessible_profiles.joins(:user_profiles)
        .where(user_profiles: { user: user, can_update: true }).exists?,
      can_delete_any: accessible_profiles.joins(:user_profiles)
        .where(user_profiles: { user: user, can_delete: true }).exists?
    }
  end
end

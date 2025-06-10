# frozen_string_literal: true

class ExpireEditRequestsService
  def self.call
    expired_edit_requests.find_each do |request|
      process_expired_request(request)
    end
  end

  def self.expired_edit_requests
    EditRequest
      .includes(:document, :user)
      .where(status: 'active')
      .where('created_at <= ?', 4.hours.ago)
  end

  def self.process_expired_request(request)
    return unless request.document&.google_file_id

    GoogleDrivePermissionService
      .new(request.document)
      .revoke_edit_access(request.user.email)

    request.update(status: 'expired')
  end
end

class Current < ActiveSupport::CurrentAttributes
  attribute :_user
  attribute :_impersonator

  resets { Time.zone = nil }

  def user=(user)
    self._user = user
    update_time_zone
  end

  def user
    _user
  end

  def impersonator=(impersonator)
    self._impersonator = impersonator
    update_time_zone
  end

  def impersonator
    _impersonator
  end

  def impersonating?
    _impersonator.present?
  end

  private

  def update_time_zone
    Time.zone = _user&.time_zone || _impersonator&.time_zone
  end
end

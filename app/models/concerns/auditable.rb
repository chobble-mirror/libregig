module Auditable
  extend ActiveSupport::Concern

  included do
    after_update_commit :log_changes
  end

  def log_changes
    changes_to_log.each do |column, values|
      audit_class.create!(
        item_id => id,
        :column_changed => column,
        :old_value => values.first,
        :user_id => Current.user.id
      )
    end
  end

  private

  def changes_to_log
    saved_changes.slice(*self.class.logged_columns)
  end

  def audit_class
    "#{self.class.name.pluralize}Audit".constantize
  end

  def item_id
    "#{self.class.name.downcase}_id"
  end

  class_methods do
    def audit_log_columns(*columns)
      @logged_columns = columns.map(&:to_s)
    end

    def logged_columns
      @logged_columns || []
    end
  end
end

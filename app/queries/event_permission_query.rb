class EventPermissionQuery
  class << self
    def permission_sql(user_id)
      <<-SQL
        EXISTS (
          SELECT 1 FROM permissions
          WHERE permissions.user_id = #{user_id}
            AND permissions.status IN ('owned', 'accepted')
            AND (
              /* Check three ways you might have permission */
              (#{direct_permission_sql})
              OR
              (#{through_band_sql})
              OR
              (#{through_member_sql})
            )
        )
      SQL
    end

    private

    def direct_permission_sql
      <<-SQL
        /* Simplest case: you have direct permission to the event */
        permissions.item_type = 'Event'
        AND permissions.item_id = events.id
      SQL
    end

    def through_band_sql
      <<-SQL
        /* You have permission to a band that's playing at this event */
        permissions.item_type = 'Band'
        AND permissions.item_id IN (
          /* Find all bands playing at this event */
          SELECT band_id
          FROM event_bands
          WHERE event_id = events.id
        )
      SQL
    end

    def through_member_sql
      <<-SQL
        /* You have permission to a member who's playing at this event */
        permissions.item_type = 'Member'
        AND permissions.item_id IN (
          /* Find all members playing at this event */
          SELECT members.id
          FROM members
          /* Connect members to their bands */
          JOIN band_members
            ON band_members.member_id = members.id
          /* Connect bands to the events they're playing */
          JOIN event_bands
            ON event_bands.band_id = band_members.band_id
          WHERE event_bands.event_id = events.id
        )
      SQL
    end
  end
end

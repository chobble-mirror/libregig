class BandPermissionQuery
  class << self
    def permission_sql(user_id)
      <<-SQL
        EXISTS (
          SELECT 1 FROM permissions
          WHERE permissions.user_id = #{user_id}
            AND permissions.status IN ('owned', 'accepted')
            AND (
              /* Check three ways you might directly have permission */
              (#{direct_permission_sql})
              OR
              (#{through_member_sql})
              OR
              (#{through_event_sql})
            )
        )
        /* Or check indirect permissions through event relationships */
        OR bands.id IN (
          /* Can see bands at events you have have permission for other bands
             at */
          #{shares_event_with_permitted_band_sql(user_id)}
        )
        OR bands.id IN (
          /* Can see bands at events you have have permission for members in
             bands at */
          #{shares_event_with_band_with_permitted_member_sql(user_id)}
        )
      SQL
    end

    private

    def direct_permission_sql
      <<-SQL
        /* Simplest case: you have direct permission to the band */
        permissions.item_type = 'Band'
        AND permissions.item_id = bands.id
      SQL
    end

    def through_member_sql
      <<-SQL
        /* You have permission to a member who is in this band */
        permissions.item_type = 'Member'
        AND permissions.item_id IN (
          /* Find all members in this band */
          SELECT member_id
          FROM band_members
          WHERE band_id = bands.id
        )
      SQL
    end

    def through_event_sql
      <<-SQL
        /* You have permission to an event this band is playing at */
        permissions.item_type = 'Event'
        AND permissions.item_id IN (
          /* Find all events this band is playing at */
          SELECT event_id
          FROM event_bands
          WHERE band_id = bands.id
        )
      SQL
    end

    def shares_event_with_permitted_band_sql(user_id)
      <<~SQL
        /* Find bands that are playing at the same events as bands you can access */
        SELECT band.id
        FROM bands AS band
        /* First, find events this band is playing at */
        JOIN event_bands AS event_band
          ON event_band.band_id = band.id
        /* Then find other bands playing at those same events */
        JOIN event_bands AS other_event_band
          ON other_event_band.event_id = event_band.event_id
        /* Check if you have permission to any of those other bands */
        JOIN permissions AS p
          ON p.item_type = 'Band'
          AND p.item_id = other_event_band.band_id
          AND p.user_id = #{user_id}
          AND p.status IN ('owned', 'accepted')
      SQL
    end

    def shares_event_with_band_with_permitted_member_sql(user_id)
      <<-SQL
        /* Find bands that are playing at events where there's another band
           that has a member you have permission to */
        SELECT band.id
        FROM bands AS band
        /* First, find events this band is playing at */
        JOIN event_bands AS event_band
          ON event_band.band_id = band.id
        /* Then find other bands playing at those same events */
        JOIN event_bands AS other_event_band
          ON other_event_band.event_id = event_band.event_id
        /* Find members in those other bands */
        JOIN band_members AS bm
          ON bm.band_id = other_event_band.band_id
        /* Check if you have permission to any of those members */
        JOIN permissions AS p
          ON p.item_type = 'Member'
          AND p.item_id = bm.member_id
          AND p.user_id = #{user_id}
          AND p.status IN ('owned', 'accepted')
      SQL
    end
  end
end

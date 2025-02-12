class MemberPermissionQuery
  class << self
    def permission_sql(user_id)
      <<~SQL
        EXISTS (
          SELECT 1 FROM permissions
          WHERE (
            permissions.user_id = #{user_id}
            AND permissions.status IN ('owned', 'accepted')
            AND (
              /* Check three ways you might directly have permission */
              (#{direct_permission_sql})
              OR
              (#{through_band_sql})
              OR
              (#{through_event_sql})
            )
          )
          /* Or check indirect permissions through various relationships */
          OR members.id IN (
            /* Can see members who are in bands with members you can access */
            #{shares_band_with_permitted_member_sql(user_id)}
          )
          OR members.id IN (
            /* Can see members who are playing at events with members you can access */
            #{shares_event_with_permitted_member_sql(user_id)}
          )
          OR members.id IN (
            /* Can see members who are in bands playing at events with bands you can access */
            #{shares_event_with_permitted_band_sql(user_id)}
          )
        )
      SQL
    end

    private

    def direct_permission_sql
      <<~SQL
        /* Simplest case: you have direct permission to see this member */
        permissions.item_type = 'Member'
        AND permissions.item_id = members.id
      SQL
    end

    def through_band_sql
      <<~SQL
        /* You have permission to a band this member plays in */
        permissions.item_type = 'Band'
        AND permissions.item_id IN (
          /* Find all bands this member is in */
          SELECT band_id FROM band_members
          WHERE member_id = members.id
        )
      SQL
    end

    def through_event_sql
      <<~SQL
        /* You have permission to an event where this member is playing */
        permissions.item_type = 'Event'
        AND permissions.item_id IN (
          /* Find all events where this member is playing */
          SELECT events.id FROM events
          /* Connect events to bands playing at them */
          JOIN event_bands ON event_bands.event_id = events.id
          /* Connect bands to their members */
          JOIN band_members ON band_members.band_id = event_bands.band_id
          WHERE band_members.member_id = members.id
        )
      SQL
    end

    def shares_band_with_permitted_member_sql(user_id)
      <<~SQL
        /* Find members who are in the same bands as members you can access */
        SELECT other_members.member_id
        /* Start with members you have permission for */
        FROM band_members AS my_bands
        /* Find other members in the same bands */
        JOIN band_members AS other_members
          ON other_members.band_id = my_bands.band_id
        /* Check that you have permission to the original member */
        JOIN permissions AS p
          ON p.item_type = 'Member'
          AND p.item_id = my_bands.member_id
        WHERE p.user_id = #{user_id}
          AND p.status IN ('owned', 'accepted')
      SQL
    end

    def shares_event_with_permitted_member_sql(user_id)
      <<~SQL
        /* Find members who are playing at the same events as members you can access */
        SELECT band_member.member_id
        /* Start with a member in a band */
        FROM band_members AS band_member
        /* Find events where their band is playing */
        JOIN event_bands AS event_band
          ON event_band.band_id = band_member.band_id
        /* Find other bands at those same events */
        JOIN event_bands AS other_event_band
          ON other_event_band.event_id = event_band.event_id
        /* Find members in those other bands */
        JOIN band_members AS other_band_member
          ON other_band_member.band_id = other_event_band.band_id
        /* Check that you have permission to one of those other members */
        JOIN permissions AS p
          ON p.item_type = 'Member'
          AND p.item_id = other_band_member.member_id
          AND p.user_id = #{user_id}
          AND p.status IN ('owned', 'accepted')
      SQL
    end

    def shares_event_with_permitted_band_sql(user_id)
      <<~SQL
        /* Find members who are playing at events where you have permission to another band */
        SELECT band_member.member_id
        /* Start with a member in a band */
        FROM band_members AS band_member
        /* Find events where their band is playing */
        JOIN event_bands AS event_band
          ON event_band.band_id = band_member.band_id
        /* Find other bands at those same events */
        JOIN event_bands AS other_event_band
          ON other_event_band.event_id = event_band.event_id
        /* Check that you have permission to one of those other bands */
        JOIN permissions AS p
          ON p.item_type = 'Band'
          AND p.item_id = other_event_band.band_id
          AND p.user_id = #{user_id}
          AND p.status IN ('owned', 'accepted')
      SQL
    end
  end
end

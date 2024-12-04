# Libregig - a band management app

⚠️ **THIS IS NOT PRODUCTION READY!! Many sections are incomplete** ⚠️

-----

Libregig is a Ruby on Rails **band management** app to handle the day-to-day of organising rehearsals and gigs. Users can:

- Create and edit bands, events, and members
- Organise tracks and tracklists
- Add attachments to items
- Share view or edit access with other users
- Receive email notifications about changes to items
- Sync events feeds via iCal and Google Calendar

Future plans include:

- Near term:
  - "Promoter" user type to organise tours across bands
  - Notifications via Whatsapp / Signal bot
- Medium term:
  - Federation, allowing tours to be planned across instances
  - Social media integration?
- Long term:
  - Ticket sales? 

-----

⚠️ **THIS IS NOT PRODUCTION READY!! Many sections are incomplete** ⚠️

## DONE:

* User account creation
* User account confirmation
* Basic model types - Event, Band, Member
* Permissions - Owner, Contributor, Viewer

## TODO

* Rails 8 upgrade
* Finish all controllers
* Data back up and restore
* Deleting bands/accounts
* Bulk email host
* Password reset flow
* Active sessions logout
* Invite flow for new users to take control of members
* Notifications
* 2FA
* Rolling subscription payments

## ONE DAY

* Theme selector
* Whatsapp bot
* Event Q&A
* Pinnable tabs
* Practice scheduling tool
* Promoter tools

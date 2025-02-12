# Libregig - a band management app

- [Test coverage (93%)](https://coverage.libregig.com/) _- updated periodically_

---

⚠️ **THIS IS NOT PRODUCTION READY!! Many sections are incomplete** ⚠️

---

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

---

⚠️ **THIS IS NOT PRODUCTION READY!! Many sections are incomplete** ⚠️

## DONE:

- User account creation
- User account confirmation
- Basic model types - Event, Band, Member
- Permissions - Owner, Contributor, Viewer

### Permissions

**Members can be accessed through:**

- (view / edit) Direct permission to the member
- (view) Permission to a band they're in
- (view) Permission to an event they're playing
- (view) Being in a band with a member you have permission to
- (view) Playing at an event with a member you have permission to
- (view) Playing at an event with a band you have permission to

**Bands can be accessed through:**

- (view / edit) Direct permission to the band
- (view) Permission to a member in the band
- (view) Permission to an event they're playing
- (view) Playing at an event with a band you have permission to
- (view) Playing at an event with a member you have permission to

**Events can be accessed through:**

- (view / edit) Direct permission to the event
- (view) Permission to a band playing at the event
- (view) Permission to a member playing at the event

## TODO

- Rails 8 users upgrade
- Finish all controllers
- Data back up and restore
- Deleting bands/accounts
- Bulk email host
- Password reset flow
- Active sessions logout
- Invite flow for new users to take control of members
- Notifications
- 2FA
- Rolling subscription payments

## ONE DAY

- Theme selector
- Whatsapp bot
- Event Q&A
- Pinnable tabs
- Practice scheduling tool
- Promoter tools

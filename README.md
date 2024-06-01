# GhostCensus
An addon built for collecting population data in World of Warcraft. Not for use in any sort of AI application.

This addon listens to a bunch of different events in the game and uses them to grab information from every character it sees.
Here's what it collects:
- Class
- Race
- Gender
- Realm

On top of the things listed above, when used alongside TotalRP3, it also collects some usage data on the custom profile fields:
- Usage of the custom voice reference field
- Usage of the custom guild field
- Usage of the custom pronouns field
- Profile icon name

This addon was used to collect population data at Tournament of Ages 2023 on MoonGuard.

Includes a few slash commands as well:
- `/gcs show <tblIndex>`: Opens a tinspect window to the database at the given string index. An example index would be a `CharacterName-RealmName` or `sourcesCount`.
- `/gcs wipe <commit>`: Wipes the database. If you specify commit (with a 1) it will automatically reload and also wipe the SavedVariables entry. If you *don't* specify commit, it will (I think, pls be careful) only wipe the working database, will not reload, and will not delete your SavedVariables entry.
- `/gcs count`: Prints the number of unique characters you've seen.
- `/gcs metrics`: Opens a tinspect window the `Metrics` table, which holds non-identifying class, race, sex, and realm numbers.

**NOTE**: I will not be providing support for this addon, it's up to you to figure out how to use it and alter it for your own use case.

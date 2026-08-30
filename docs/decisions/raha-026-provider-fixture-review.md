# RAHA-026 Provider Fixture Review

**Decision owner:** Adel  
**Decision date:** 2026-08-30  
**Status:** Deferred to the beta/release gate; not blocking development

The tracked `Free50/` baseline contains provider JSON and raw MP4/GIF files.
The product owner confirms that this is the provider's free sample package and
approves it for temporary internal development and testing while Raha Move is
being built. It is fixture content, not production mobility content.

This decision closes the RAHA-026 development blocker. It does not claim that
"free" means unrestricted redistribution rights. Until the release review is
complete, the Free50 files must not be:

- published as Raha Move exercises;
- included in a beta or production application build;
- uploaded to a public bucket or exposed by unrestricted URLs; or
- used in marketing, resale, or distribution to end users.

Before beta distribution, the Product and Security/Privacy owners must complete
the RAHA-082/RAHA-084 release gate and record one outcome:

1. Purchase or otherwise license the production mobility assets and confirm
   that the planned app, CDN, caching, and offline behavior is permitted; and
   remove the Free50 development fixtures from release source and build inputs;
   or
2. Obtain written provider permission covering any Free50 files that must remain
   in the private repository, including permitted collaborators, retention, and
   backup/history handling.

If neither outcome is available, remove the tracked provider binaries and
restricted metadata, replace them with authored or clearly redistributable test
fixtures, and assess whether repository-history cleanup is required. Any history
rewrite requires a separate, explicit approval because it affects collaborators.

No license document, invoice, key, unrestricted source URL, or commercial
record should be committed as evidence. Store that evidence in the approved
private legal/vendor system and record only its internal reference here.

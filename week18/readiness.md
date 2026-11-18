# INFOMAN1 Week 18 Release-Readiness Audit (Ongoing Assessment 6)

*Note: Administrative readiness audit (Ongoing Assessment 6), separate from the final exam score.*

## 1. File Manifest & Source Cross-References

| Deliverable | INFOMAN1 File / Path | Linked Source / Evidence | Status |
|---|---|---|---|
| Final submission & limitations | [`submission.md`](submission.md) | `webdev2` branch `finals` (`docs/week18/submission.md`) | Ready (`<PENDING_UNLISTED_YOUTUBE_URL>`) |
| Final defense rationale | [`lecture.md`](lecture.md) | `week14/transactions.sql`, `week16/verification.sql` | Ready (awaiting video timestamps) |
| Consolidated SQL & config release | [`release/`](release/) (`01_schema.sql`–`04_access_control.sql`, `backup.sql`, `application-example.properties`) | Matches `webdev2` `finals` JPA schema (`ddl-auto=validate`) | Complete |
| Setup & safe restore runbook | [`setup.md`](setup.md) | Reproduces clean DB install & separate restore | Complete |
| Test matrix & evidence | [`test_matrix.md`](test_matrix.md), [`evidence/`](evidence/) | SQL constraints, savepoints, grants, restore, `16/16` verify | Complete |

## 2. Contributor & Scope Declaration

- **Sole Author:** Jan Liam E. Arias (`2510499`, Git author `Jan Liam Arias <100700937+Grudge10@users.noreply.github.com>`).
- **Known Limitations:** Recorded in [`submission.md`](submission.md) (local HTTP dev cookie flag, env-seeded staff logins, sanitized zero-hash `backup.sql`).

## 3. Repository, Video Playback & Submission Checklist

- [x] SQL release bundle (`01_schema.sql`–`04_access_control.sql`, `application-example.properties`, `backup.sql`) verified complete and free of real passwords or password hashes
- [x] Consolidated `evidence/` outputs match `webdev2` `finals` (`16/16` passing tests) and clean restore checks
- [ ] Public/grader repository accessibility & final `week18/` URL checked after pushing Week 18 (`https://github.com/Grudge10/infoman1/tree/main/week18`)
- [ ] Combined walkthrough video uploaded to YouTube as **Unlisted**, signed-out playback & audio clarity verified, and `<PENDING_UNLISTED_YOUTUBE_URL>` + timestamps filled (`<PENDING_CHECK>`)

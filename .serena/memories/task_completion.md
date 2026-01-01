# Task Completion Checklist
- Ensure code formatted via `dart format lib test` and passes `flutter analyze` and `flutter test` before finalizing.
- Update or add tests for new functionality; place under `test/feature_name/` with descriptive `whenExpectedOutcome` group names.
- Document worklogs in `__prompts/_task/` as `YYYY-MM-DD-HH-MM_<title>.md` and maintain plan docs in `__prompts/_plan/` per request.
- Verify Supabase configs remain valid and environment-specific secrets are not leaked in commits.
- Provide change summary, test evidence, and (if UI modified) before/after visuals in PRs; link related issues with `Closes #<id>`.
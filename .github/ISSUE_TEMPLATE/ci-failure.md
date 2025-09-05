<!-- [CI Failure Report Template] -->
# ⚠️ CI Failure Report

**Workflow:** {{WORKFLOW_NAME}}  
**Run ID:** {{RUN_ID}}  
**Run URL:** {{RUN_URL}}  
**Repository:** {{REPO}}  
**Ref:** {{REF}}

---

## Job Results
- flake-check: {{RESULT_FLAKE_CHECK}}
- code-quality: {{RESULT_CODE_QUALITY}}
- test-dependency-updates: {{RESULT_DEP_UPDATE}}

---

## Failure Details
<details>
<summary>Logs / Error Summary</summary>

```
{{ERROR_LOGS}}
```

</details>

---

## Next Steps
- [ ] Investigate failing job(s)
- [ ] Assign engineer / agent to review
- [ ] Confirm fix and close issue

---

_This issue is automatically created/updated by GitHub Actions (CI workflow)._

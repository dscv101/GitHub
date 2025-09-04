---
name: Bug report
about: Create a report to help us improve
title: ''
labels: enhancement
assignees: ''

---

---
name: 🐛 Bug Report (Markdown)
about: Report a bug for Claude Sonnet 4.1 to analyze and fix (Markdown version)
title: '[BUG] '
labels: 'bug, needs-triage'
assignees: ''
---

## 🤖 Claude-Optimized Bug Report
*This template provides Claude Sonnet 4.1 with comprehensive context for efficient bug analysis and resolution.*

**Auto-labeling:** Severity levels will automatically apply priority labels for triage.

### Bug Title
<!-- Clear, concise description of the bug -->
**Bug:** 

### Severity Level
<!-- Impact level of this bug (auto-applies priority labels) -->
**Severity:** 
- [ ] Critical (system down, data loss, security breach) [+priority-critical]
- [ ] High (major feature broken, significant performance degradation) [+priority-high]
- [ ] Medium (minor feature issues, workaround available) [+priority-medium]
- [ ] Low (cosmetic issues, edge cases, documentation) [+priority-low]

### Bug Category
<!-- Type of bug encountered (auto-applies category labels) -->
**Category:**
- [ ] Runtime Error/Exception [+runtime-error]
- [ ] Performance Issue [+performance]
- [ ] Data Corruption/Loss [+data-integrity]
- [ ] Integration Failure [+integration]
- [ ] Security Vulnerability [+security]
- [ ] UI/UX Problem [+ui-ux]
- [ ] Configuration Issue [+configuration]
- [ ] Test Failure [+testing]

### Bug Description
<!-- Detailed description of the issue -->
**What happened:**
- What were you trying to do?
- What went wrong?
- What was the impact?

### Expected Behavior
<!-- What should have happened instead? -->
**Expected:**

### Actual Behavior
<!-- What actually happened? -->
**Actual:**

### Steps to Reproduce
<!-- Detailed steps to reproduce the bug -->
1. 
2. 
3. 
4. 

### Error Output/Stack Trace
<!-- Complete error messages, stack traces, or exception details -->
```
[Paste error output here]
```

### Environment Details
<!-- System and software environment information -->
**Operating System:** 
**Python Version:** 
**UV Version:** 
**Nix Flake Hash:** 
**Available Memory:** 
**CPU:** 
**Disk Space:** 

### Dependency Versions
<!-- Key package versions (from uv.lock or pip list) -->
```
pandas==
numpy==
sqlalchemy==
psutil==
```

### SQL Server Context (if applicable)
<!-- Database-related information for SQL issues -->
**SQL Server Version:** 
**Database Name:** 
**Table Schema:** 
**Query Performance:** 
**Connection String:** 

### Nix Environment Details
<!-- Nix configuration and environment information -->
**Nix Version:** 
**Flake Configuration:** 
**Development Shell:** 
**Build Environment:** 
**System Packages:** 

### GitHub Actions CI Logs
<!-- Relevant CI/CD pipeline logs and failures -->
**Workflow Name:** 
**Job Name:** 
**Run ID:** 
**Failure Step:** 

```
[Paste relevant log sections here]
```

### Local Development Logs
<!-- Local application logs, debug output, or console messages -->
```
[Paste local logs here]
```

### Performance Data (for performance bugs)
<!-- Profiling data, benchmarks, memory usage, timing information -->
**Memory Usage:** 
**CPU Usage:** 
**Processing Speed:** 
**Profiling Data:** 
**Benchmark Comparison:** 

### Suspected File Locations
<!-- Files where you suspect the bug originates -->
- 
- 
- 

### Related Code Context
<!-- Relevant code excerpts that provide context -->
```python
# From [file path] around line [number]
[Code excerpt here]
```

### Existing Test Context
<!-- Related tests that are failing or should be modified -->
**Failing Tests:**
- 
- 

**Tests to Update:**
- 
- 

### Test Requirements for Fix
<!-- New tests that should pass after the bug is fixed -->
- [ ] 
- [ ] 
- [ ] 

### Debugging Steps Attempted
<!-- What debugging approaches have you tried? -->
- [ ] Reviewed logs and error messages
- [ ] Ran with debug logging enabled
- [ ] Tested with smaller datasets
- [ ] Profiled memory usage
- [ ] Checked dependency versions
- [ ] Tested in clean environment
- [ ] Reviewed recent code changes
- [ ] Consulted documentation
- [ ] Searched for similar issues

### Tool Analysis Results
<!-- Results from development tools -->
- [ ] pytest: Tests pass locally
- [ ] pytest: Tests fail locally
- [ ] mypy: Type checking passes
- [ ] mypy: Type checking fails
- [ ] ruff: Linting passes
- [ ] ruff: Linting fails
- [ ] bandit: Security scan passes
- [ ] bandit: Security scan fails
- [ ] coverage: Coverage above threshold
- [ ] coverage: Coverage below threshold

### Temporary Workaround
<!-- Any temporary solutions or workarounds you've found -->


### Reproducibility
<!-- How consistently can this bug be reproduced? -->
- [ ] Always (100% of the time)
- [ ] Frequently (>75% of the time)
- [ ] Sometimes (25-75% of the time)
- [ ] Rarely (<25% of the time)
- [ ] Unable to reproduce locally

### Additional Context
<!-- Any other information that might help Claude understand and fix the issue -->
- Recent changes that might be related:
- Similar issues encountered before:
- Business impact or urgency:
- Constraints or requirements for the fix:

### Fix Requirements
<!-- Requirements for the bug fix -->
- [ ] Maintain backward compatibility
- [ ] Include comprehensive tests
- [ ] Update documentation
- [ ] Performance must not regress
- [ ] Security implications considered
- [ ] Database migration required
- [ ] Configuration changes needed
- [ ] Breaking change acceptable

### Success Criteria
<!-- How will we know the bug is completely fixed? -->
- [ ] 
- [ ] 
- [ ] 

---

## 🤖 Claude Analysis Hints
*Hidden section for Claude Sonnet 4.1 optimization*

### Bug Analysis Priority:
1. **Critical/High Severity**: Focus on immediate stability and data integrity
2. **Performance Issues**: Profile first, optimize second - measure before/after
3. **Runtime Errors**: Trace stack, identify root cause, implement defensive coding
4. **Integration Failures**: Check version compatibility, configuration, and environment

### Code Investigation Strategy:
- Start with suspected files and error stack traces
- Use `@` syntax to examine related files if context is insufficient
- Look for recent commits that might have introduced the regression
- Check for similar patterns in the codebase that work correctly

### Fix Implementation Approach:
- Implement minimal viable fix first, then optimize
- Add comprehensive error handling and logging
- Include both positive and negative test cases
- Consider edge cases and boundary conditions
- Ensure thread safety for concurrent operations

### Testing Strategy:
- Write failing test first (TDD approach)
- Include regression tests to prevent reoccurrence
- Test with realistic data volumes and conditions
- Validate performance impact with benchmarks
- Test error handling and recovery scenarios

### Tool-Specific Considerations:
- **UV**: Check dependency resolution and version conflicts
- **Pytest**: Ensure test isolation and proper fixtures
- **Mypy**: Maintain type safety, add annotations if missing
- **Ruff**: Follow linting rules, fix any new violations
- **Bandit**: Address security implications of the fix
- **Pandas/Polars**: Consider memory efficiency and vectorization

### Environment-Specific Notes:
- **NixOS**: Ensure reproducible builds and environment consistency
- **SQL Server 13**: Check compatibility and query optimization
- **GitHub Actions**: Validate CI/CD pipeline compatibility

### Communication Protocol:
- Acknowledge bug severity and provide ETA for investigation
- Request additional context if retrieval fails to find relevant code
- Explain the root cause clearly in technical terms
- Provide step-by-step fix implementation plan
- Include prevention strategies for similar issues

### Auto-Labeling Rules:
```yaml
# Severity-based labels
Critical → priority-critical, urgent
High → priority-high, important
Medium → priority-medium
Low → priority-low

# Category-based labels
Runtime Error/Exception → runtime-error, needs-investigation
Performance Issue → performance, optimization
Data Corruption/Loss → data-integrity, critical
Integration Failure → integration, dependencies
Security Vulnerability → security, urgent
UI/UX Problem → ui-ux, user-experience
Configuration Issue → configuration, environment
Test Failure → testing, ci-cd
```

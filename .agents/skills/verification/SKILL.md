---
name: verification
description: Verify a change in health-tracker-aws before reporting it as done, committing it or opening a PR. Use after editing Java code, tests, pom.xml or application properties.
---

# Verification

Run these steps and report the real results. If a step could not run, say so and why.

1. **Build and tests:** `./mvnw verify` (in PowerShell: `.\mvnw.cmd verify`). Check the exit code and the
   test summary (`Tests run: X, Failures: 0, Errors: 0, Skipped: 0`). Any skipped test must be explained.
   A hook also runs it at the end of each turn when code changed (`scripts/verify.sh`), but run it
   yourself to see the full summary before reporting.
2. **New behavior is tested:** every new or changed endpoint has a test (`@WebMvcTest` + `MockMvc`, like
   `ping/PingControllerTest`). If not, write it before going on.
3. **Run the app** when an endpoint, configuration or dependency changed: start it with
   `./mvnw spring-boot:run` in the background, call the affected endpoints on `http://localhost:8080`
   (for example `curl -s http://localhost:8080/ping`), check status code and body, then stop the app.
4. **Review the diff:** `git status` and `git diff`. Only intended files changed; nothing from `target/`,
   `.idea/` or local config is staged; package declarations match their folders.
5. **Report:** what ran, the outcome (with the failing output if something failed) and what was not
   verified. CI also runs `./mvnw -B verify` on the PR: check it passes (`gh pr checks`).

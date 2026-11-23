# health-tracker-aws (backend on AWS)

A version of the Health Tracker backend meant to run on AWS, instead of the current one on Google Cloud
(`../health-tracker`: Firestore + Cloud Run). See `../CLAUDE.md` for the overall project.

It is at a very early stage: a Spring Boot skeleton with only a `GET /ping` endpoint
(`ping/PingController`). There is no persistence, security or deployment yet. CI
(`.github/workflows/ci.yml`) runs `./mvnw -B verify` on every pull request.

## Stack

- Java 25, Spring Boot 4.2 (`spring-boot-starter-webmvc`, validation), Lombok, Maven wrapper.
- Base package: `dev.rafatoba.health_tracker_aws`.

## Commands

- Build and test: `./mvnw verify` (on Windows PowerShell: `.\mvnw.cmd verify`).
- Run locally: `./mvnw spring-boot:run`, then `GET http://localhost:8080/ping`.

## Conventions

- Unless a decision for this repo says otherwise, follow the conventions of `../health-tracker/CLAUDE.md`
  (one package per feature, uid from the JWT, Problem Details errors, `/api/v1/...`, cursor pagination,
  three tests per resource), replacing the Firestore/GCP specifics with their AWS equivalents.
  Ask the user before choosing AWS services (database, compute, auth), since they are not decided yet.
- Controller tests use `@WebMvcTest` with `MockMvc` (see `PingControllerTest`).
- Git: repo `rafatoba/health-tracker-aws`. Work on a branch and open a PR; don't push to `main`.

## Agent files

- `AGENTS.md` (this file) holds the instructions for every coding agent (Claude Code, Mistral Vibe, ...).
  `CLAUDE.md` only imports it (`@AGENTS.md`); put shared instructions here, not there.
- Skills live in `.agents/skills/<name>/SKILL.md` (read by Mistral Vibe). Claude Code only reads
  `.claude/skills/`, so each skill there is a short stub pointing to the `.agents/` one.
- Before saying a change is done, follow the `verification` skill.

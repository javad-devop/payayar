# AGENTS.md --- Project Rules & Architecture

## 1. Project Identity

This project is a lightweight, local-first study and life-management
application for Iranian exam-preparation students (کنکوری).

The application is intended to help the student manage:

-   Long-term exam preparation
-   Strategic planning
-   Exam-cycle / two-week planning
-   Weekly planning
-   Daily 24-hour scheduling
-   Study, tests, and review
-   Exam records and analysis
-   Progress reporting
-   Lifestyle tracking
-   AI-assisted planning and analysis

The student is the owner of the plan. The application is a tool, not an
autonomous planner.

------------------------------------------------------------------------

## 2. Highest-Priority Product Principles

These principles are more important than individual implementation
preferences.

1.  **Local-first**
    -   User data must live on the user's device by default.
    -   Do not introduce a backend, cloud database, remote user
        database, or account system unless explicitly requested.
2.  **Lightweight**
    -   Keep the application simple, fast, and resource-efficient.
    -   Avoid unnecessary dependencies, services, frameworks, background
        workers, telemetry, analytics, synchronization layers, queues,
        or infrastructure.
3.  **User-controlled planning**
    -   The student manually owns and controls the plan.
    -   AI may suggest, analyze, draft, or prepare changes, but must not
        silently take ownership of the student's plan.
4.  **AI is an assistant, not the product owner**
    -   AI must help the user, not make irreversible decisions without
        confirmation.
    -   AI-generated modifications to important user data should
        normally require explicit user confirmation.
5.  **Preserve existing behavior**
    -   Existing working functionality is considered intentional unless
        the user explicitly requests a change.
    -   Do not refactor working code merely for stylistic reasons.
6.  **Smallest safe change**
    -   Prefer the smallest change that solves the requested problem.
    -   Avoid broad rewrites when a targeted fix is sufficient.
7.  **Do not silently change architecture**
    -   Never replace the stack, database, storage model, AI provider
        strategy, navigation structure, or major architectural pattern
        without explicit approval.

------------------------------------------------------------------------

## 2.1. Product Name & Brand Identity

The current product name is **پایا‌یار (Payayaar)**.

-   Use **پایا‌یار** as the product name in Persian UI, documentation,
    and product-facing text unless the user explicitly requests another
    form.
-   The English/Latin brand form may be written as **PAYAYAR** where
    appropriate.
-   The name should not force the product to remain limited to "کنکور";
    the product may later expand to broader student planning and study
    use cases without requiring a brand change.
-   UI copy and visual identity should feel clean, professional, modern,
    and intentionally designed rather than resembling generic
    AI-generated dashboards.
-   Do not introduce a new product name, logo concept, or brand identity
    without explicit approval.

## 3. Target Platforms

Primary targets:

-   Windows
-   Android

Possible future target:

-   iOS

The project should be designed so that adding another supported platform
later does not require rewriting the entire application.

------------------------------------------------------------------------

## 4. Current Technology Direction

### Primary candidate stack

The current preferred direction is:

-   **Flutter**
-   **Dart**
-   **SQLite** for local application data
-   A lightweight SQLite abstraction such as **Drift** if needed
-   **Riverpod** or another lightweight, clearly justified
    state-management approach
-   **fl_chart** or a similarly lightweight charting package
-   Secure device storage for sensitive settings such as AI credentials
-   **Gemini API** as the initial AI provider

### Important status

The exact dependency list is not permanently locked until the
implementation phase confirms compatibility with the selected Vibe
Coding workflow.

A coding agent must **not** replace Flutter with Tauri, React Native,
.NET MAUI, Kotlin Multiplatform, or another framework unless the user
explicitly requests or approves that change.

If the user later chooses Tauri/Rust instead, this file must be updated
before a large migration is attempted.

------------------------------------------------------------------------

## 5. Data Architecture

### Local database

The application's primary data store should be local SQLite.

High-level data domains may include:

-   User settings
-   Subjects
-   Topics / chapters
-   Sources / study resources
-   Roadmap items
-   Strategic plans
-   Exam cycles
-   Weekly plans
-   Daily schedules
-   Planned activities
-   Study sessions
-   Test sessions
-   Review items
-   Exams
-   Exam results
-   Lifestyle records
-   Sleep records
-   Exercise records
-   Nutrition records
-   Mobile/device-usage records when supported
-   Daily reflections
-   AI settings / provider settings

Exact schema names are implementation details and may evolve.

### Important data rule

Separate **planned data** from **actual performance data**.

Example:

-   Planned: 2 hours of mathematics
-   Actual: 1h 25m mathematics + 23 tests + 18 correct + 3 wrong + 2
    unanswered

Do not collapse these into one field or overwrite the plan with actual
results.

------------------------------------------------------------------------

## 6. Privacy & Storage Rules

### Must

-   Store normal user data locally.
-   Keep AI provider settings locally.
-   Store the user's AI credential using appropriate secure storage when
    supported by the platform.
-   Send only the minimum context required for an AI request.
-   Keep the application useful without an internet connection whenever
    the requested feature does not inherently require AI/network access.

### Must not

-   Do not create a server-side database for normal user data.
-   Do not send all user history to the AI provider by default.
-   Do not upload the local SQLite database automatically.
-   Do not add telemetry or analytics without explicit approval.
-   Do not collect user data for product analytics by default.
-   Do not create silent background synchronization.
-   Do not add third-party tracking SDKs unless explicitly requested.
-   Never hard-code a private/shared API key into the application source
    code.
-   Never expose one user's API key to another user.

------------------------------------------------------------------------

## 7. AI Architecture

AI is a cross-cutting capability available throughout the application.

There are two primary AI interaction modes.

### A. Contextual AI inside each section

Every important section may expose a contextual AI action, for example:

-   "کمک AI"
-   "تحلیل با AI"
-   "پیشنهاد با AI"
-   "بررسی با AI"

The AI receives the minimum relevant context from the current section.

Examples:

-   Weekly planner → weekly schedule + relevant exam context
-   Exam page → exam results + relevant history
-   Reports → selected report data
-   Lifestyle → relevant lifestyle records

The AI should not receive unrelated data just because it exists.

### B. Standalone AI Advisor

A dedicated AI Advisor / مشاور AI section provides broader conversation
across the application.

It may use relevant application data with the user's knowledge and
should be able to move the user toward the relevant section when
appropriate.

------------------------------------------------------------------------

## 8. AI Actions

AI should not be limited to text replies.

It may produce structured actions such as:

-   Create a draft plan
-   Suggest moving an activity
-   Suggest adding a topic
-   Suggest a weekly structure
-   Analyze an exam
-   Suggest a review
-   Identify schedule conflicts
-   Identify missed activities
-   Propose schedule adjustments

### Critical rule: confirmation before important mutations

For important changes, the default flow is:

1.  AI analyzes current state.
2.  AI produces a structured proposal.
3.  User sees the proposal.
4.  User explicitly approves, edits, or rejects it.
5.  Only then is the local data modified.

Do not let AI silently mutate the user's important plans.

------------------------------------------------------------------------

## 9. AI Safety / Anti-Corruption Rules

A coding agent must not implement AI behavior that can unexpectedly
damage or rewrite large amounts of user data.

### Never allow AI to:

-   Delete a user's complete plan without confirmation.
-   Replace a full week's schedule silently.
-   Rewrite the roadmap silently.
-   Delete exam history silently.
-   Delete study history silently.
-   Delete lifestyle history silently.
-   Overwrite user-created content because an AI response was generated.
-   Execute bulk destructive operations without explicit confirmation.
-   Modify database schema dynamically from an ordinary chat response.
-   Run arbitrary SQL generated by an LLM directly against the
    production user database.
-   Execute arbitrary filesystem commands generated by an LLM.
-   Install packages or modify build configuration based only on an AI
    response.

### Safe default

AI output must be treated as **untrusted proposed data** until validated
by the application.

Validate structured AI actions before applying them.

------------------------------------------------------------------------

## 10. Planning System

The planning hierarchy is:

``` text
🗺️ Roadmap / Strategic Direction
        ↓
🎯 Strategic Plan
        ↓
🧪 Exam Cycle / Two-Week Plan
        ↓
📅 Weekly Plan
        ↓
⏰ Daily 24-Hour Plan
        ↓
✅ Execution
        ↓
📊 Actual Performance
        ↓
📈 Reports
        ↓
🤖 AI Suggestions
```

The hierarchy is connected, but the levels must remain understandable
and manually controllable.

### Planning levels

#### 1. Roadmap

The student's long-range map:

-   Main goals
-   Date ranges
-   Subjects
-   Topics
-   Priorities
-   Resources
-   Milestones
-   Major exams
-   Review / consolidation phases

#### 2. Strategic Plan

Defines what should be achieved in larger time periods.

#### 3. Exam Cycle / Two-Week Plan

Designed around the user's upcoming mock/simulation exam or other exam
cycle.

The student manually enters the exam and the covered topics.

#### 4. Weekly Plan

The primary planning workspace.

Activities may contain fields such as:

-   Subject
-   Topic
-   Activity type
-   Start time
-   End time
-   Duration
-   Goal
-   Test count target
-   Resource
-   Notes
-   Status

#### 5. Daily 24-Hour Plan

A full-day timeline that may contain:

-   Study
-   Tests
-   Review
-   Sleep
-   Meals
-   Exercise
-   Rest
-   Classes
-   Transportation
-   Personal time
-   Other activities

The daily timeline is not limited to academic activities.

------------------------------------------------------------------------

## 11. Activity Statuses

Activities may support states such as:

-   Not started
-   In progress
-   Completed
-   Cancelled
-   Moved / Rescheduled
-   Skipped / Ignored

Statuses should remain explicit rather than inferring completion from
missing data.

------------------------------------------------------------------------

## 12. Lifestyle Module

The lifestyle area is intentionally lightweight.

Core sections:

-   Sleep
-   Exercise
-   Nutrition
-   Mobile/device use
-   Rest and recreation
-   Daily reflection

### Sleep

Possible fields:

-   Sleep time
-   Wake time
-   Duration
-   Quality
-   Nap information

### Exercise

Possible fields:

-   Activity type
-   Duration
-   Intensity
-   Date/time

### Nutrition

Keep this lightweight; this is not a full nutrition/medical app.

Possible fields:

-   Main meals
-   Water
-   Simple daily note/rating

### Mobile use

Manual tracking may be used initially.

### Rest / recreation

Allow non-academic time to appear in the same daily timeline.

### Daily reflection

Potential entries:

-   Study time
-   Test count
-   Sleep
-   Exercise
-   Mobile use
-   Energy
-   Focus
-   Main difficulty of the day
-   Free-text note

------------------------------------------------------------------------

## 13. Study / Test / Review Module

The study system should distinguish at least:

-   Study
-   Test practice
-   Review

A study activity should be linkable to:

-   Subject
-   Topic
-   Planned duration
-   Actual duration
-   Optional resource
-   Optional note

Test records may include:

-   Subject
-   Topic
-   Number of tests
-   Correct
-   Wrong
-   Unanswered
-   Duration
-   Source
-   Optional note

Review records should be able to connect to the relevant topic and
review date.

------------------------------------------------------------------------

## 14. Exam Module

The exam area should support:

-   Creating an exam manually
-   Date/time
-   Duration
-   Subjects
-   Covered topics
-   Results
-   Correct/wrong/unanswered counts
-   Percentages
-   Analysis
-   Comparison across previous exams

AI may analyze the results, but the stored result data remains
authoritative.

------------------------------------------------------------------------

## 15. Reports & Analytics

Reports should be generated locally from stored data whenever possible.

Potential reports:

-   Study hours
-   Test counts
-   Correct/wrong/unanswered
-   Plan completion
-   Planned vs actual performance
-   Subject distribution
-   Topic progress
-   Sleep trends
-   Exercise trends
-   Mobile-use trends
-   Weekly / biweekly trends
-   Exam performance trends

Do not introduce an analytics service merely to generate charts that can
be calculated locally.

------------------------------------------------------------------------

## 16. Dashboard / Home

The home screen should answer quickly:

-   What is planned today?
-   What has been completed?
-   What remains?
-   What is the current progress?
-   When is the next exam?
-   What important AI insight or suggestion is available?

Avoid turning the dashboard into an overloaded data wall.

------------------------------------------------------------------------

## 17. Navigation Structure

Current high-level navigation:

``` text
🏠 Home
📅 Planning
📚 Study
📝 Exams
📊 Reports
🌱 Lifestyle
🤖 AI Advisor
⚙️ Settings
```

The exact navigation UI may change, but these product areas must remain
conceptually distinct.

------------------------------------------------------------------------

## 18. Vibe Coding Rules for AI Agents

This project is expected to be developed with AI coding tools.

Therefore every coding agent must follow these rules.

### Before editing

1.  Inspect the existing project structure.
2.  Read the relevant files before changing them.
3.  Identify dependencies and existing architecture.
4.  Understand current behavior.
5.  Check whether the requested behavior already exists.

### While editing

-   Make the smallest safe change.
-   Reuse existing components and services.
-   Avoid duplicate implementations.
-   Keep names and conventions consistent with the project.
-   Do not create parallel architectures without a reason.
-   Do not replace working code with a new pattern only because it is
    fashionable.

### After editing

-   Check for syntax/build errors.
-   Check affected functionality.
-   Check imports and dependency consistency.
-   Do not claim a feature is complete without verifying the relevant
    behavior.

------------------------------------------------------------------------

## 19. Do Not Break These Things

An AI coding agent must NOT, without explicit approval:

-   Replace Flutter with another framework.
-   Replace SQLite with a server/cloud database.
-   Introduce a backend.
-   Add user authentication for convenience.
-   Add mandatory cloud synchronization.
-   Add mandatory accounts.
-   Add telemetry/analytics.
-   Add advertising SDKs.
-   Add payment systems.
-   Add social networking features.
-   Add unnecessary AI agent frameworks.
-   Introduce multiple AI providers when one provider is sufficient for
    the current scope.
-   Change the data model in a destructive way.
-   Delete existing migrations.
-   Drop tables containing user data.
-   Reset local databases automatically.
-   Clear user settings during an update.
-   Store API keys in source code.
-   Commit secrets.
-   Send the complete local database to an AI provider.

------------------------------------------------------------------------

## 20. Dependency Rules

Before adding a package:

1.  Check whether the same capability already exists in the project.
2.  Prefer a small, well-maintained dependency.
3.  Avoid adding a package for a trivial feature that can be implemented
    locally.
4.  Do not add large frameworks for features that only need a few
    functions.
5.  Do not add AI/agent orchestration frameworks unless the actual
    project requirements justify them.
6.  Keep dependency count intentionally low.

------------------------------------------------------------------------

## 21. Data Migration Rules

Database changes are high-risk.

### Must

-   Use migrations for schema changes when the chosen database layer
    supports them.
-   Preserve existing user data.
-   Handle older app versions when practical.
-   Test migration paths.

### Must not

-   Drop tables as a shortcut.
-   Recreate the database on startup to solve schema problems.
-   Delete records to make a migration succeed.
-   Change IDs or foreign-key relationships casually.

------------------------------------------------------------------------

## 22. User Data Ownership

The user owns the data.

The application must behave as though local user data is valuable and
irreplaceable.

Never assume test data can be deleted just because it is stored locally.

Features that clear, reset, import, export, overwrite, or migrate large
datasets should be explicit and user-visible.

------------------------------------------------------------------------

## 23. AI Credential Rules

The initial AI provider is Gemini using the user's own API key.

Expected flow:

``` text
User obtains their own Gemini API key
            ↓
User enters it in Settings
            ↓
App stores it locally using secure storage when available
            ↓
App sends only required AI requests to Gemini
```

Do not hard-code or share a project-owned API key.

Do not build a server just to proxy a user-owned key unless the user
explicitly changes the architecture requirement.

------------------------------------------------------------------------

## 24. AI Context Rules

Use contextual, minimal prompts.

Example:

``` text
Current screen: Weekly Plan
Relevant exam: Exam #5 on 20 Mehr
Current week goal: 40 study hours
Current planned hours: 36
Missed activities: 3
Relevant subjects/topics: ...
```

Do not automatically attach:

-   all historical records
-   the entire SQLite file
-   unrelated lifestyle records
-   all exams ever taken
-   all notes

unless the feature explicitly requires broader context and the user has
authorized the use of that context.

------------------------------------------------------------------------

## 25. AI Output Validation

LLM output must not be trusted as executable application logic.

When AI proposes structured changes:

1.  Parse the structured output.
2.  Validate types and allowed fields.
3.  Validate referenced IDs.
4.  Validate dates and time ranges.
5.  Validate that the proposed action is permitted.
6.  Present a user-readable summary.
7.  Ask for confirmation when required.
8.  Apply only validated changes.

Never directly execute arbitrary AI-generated code or SQL.

------------------------------------------------------------------------

## 26. UI/UX Principles

The interface should be:

-   Clean
-   Modern
-   Fast
-   Understandable in Persian
-   Responsive across Windows and mobile
-   Low-friction for repetitive daily entry

Avoid:

-   unnecessary screens
-   excessive animations
-   dense dashboards
-   long forms where quick input is possible
-   forcing users to enter duplicate information

Daily logging should be fast enough that the user will realistically
keep using it.

------------------------------------------------------------------------

## 27. Product Scope Guardrails

This is not intended to become a large social platform in the initial
version.

Do not add the following unless explicitly requested:

-   Social network
-   Chat between students
-   Marketplace/store
-   Online courses
-   Payment system
-   Large cloud question bank
-   Mandatory cloud sync
-   Parent monitoring platform
-   Complex gamification system
-   Full medical or nutritional system

Keep the core focused on:

**Plan → Execute → Record → Analyze → Improve**

------------------------------------------------------------------------

## 28. Core Product Loop

The most important product loop is:

``` text
Student creates plan
        ↓
Student executes plan
        ↓
Student records actual performance
        ↓
App calculates local reports
        ↓
AI analyzes relevant context
        ↓
AI suggests improvements
        ↓
Student approves/edits suggestions
        ↓
Approved changes return to the plan
```

This loop is more important than adding more features.

------------------------------------------------------------------------

## 29. Change-Control Rule

If a requested change conflicts with any major rule in this file, the
coding agent must:

1.  Stop the implementation of the conflicting change.
2.  Explain exactly which project rule would be affected.
3.  Ask for explicit approval before changing the architecture or rule.

A coding agent must never silently "improve" the project's architecture
in a way that violates this document.

------------------------------------------------------------------------

## 30. Final Rule for All Coding Agents

**Preserve the product intent before optimizing the implementation.**

When uncertain, prefer:

-   less infrastructure
-   less data movement
-   fewer dependencies
-   fewer hidden behaviors
-   reversible changes
-   explicit user control
-   local computation
-   local storage
-   transparent AI suggestions
-   small, testable modifications

Do not turn a simple local student application into a complex cloud
platform unless the user explicitly asks for that change.

------------------------------------------------------------------------

# 31. Project Constitution & Stack Lock

The following project decisions are protected unless the user explicitly
requests a change.

``` text
Product: PAYAYAR / پایا‌یار
Frontend: Flutter
Platforms: Windows + Android
Architecture: Local-first
Local database: SQLite
Backend: None by default
Cloud database: None by default
Cloud sync: None by default
AI: User-provided AI API
Primary AI provider currently planned: Gemini API
```

### Rules

-   Do not replace Flutter with another framework without explicit user
    approval.
-   Do not introduce a backend, cloud database, mandatory cloud sync, or
    hosted application architecture without explicit approval.
-   Do not replace SQLite with another database without explicit
    approval.
-   Do not add a large framework or infrastructure layer merely because
    it is available.
-   If a new dependency is necessary, prefer the smallest mature
    solution that satisfies the requirement.
-   Any proposed architecture change must explain why the current
    architecture is insufficient.

------------------------------------------------------------------------

# 32. AGENTS vs design.md

These two documents have different responsibilities.

### `AGENTS.md`

Defines:

-   Product scope
-   Architecture
-   Data ownership
-   Database rules
-   AI behavior
-   Security/privacy rules
-   Dependencies
-   Development workflow
-   Testing
-   Change control
-   Project-level engineering rules

### `design.md`

Defines:

-   Visual identity
-   UI/UX
-   Typography
-   Colors
-   Layout
-   Responsive behavior
-   Components
-   Dark/Light themes
-   Persian/English presentation
-   Visual QA

### Rule

For any UI task, the AI coding agent must read **both** files.

Do not duplicate detailed visual rules from `design.md` into this file
unless a project-level engineering rule requires them.

If the two documents appear to conflict, stop and identify the conflict
rather than silently choosing a new design or architecture.

------------------------------------------------------------------------

# 33. Plan Before Significant Changes

For non-trivial tasks, the agent should not immediately modify the
codebase.

### Required workflow

``` text
User request
    ↓
Inspect relevant project files
    ↓    Read AGENTS.md
    ↓
Read design.md when UI is affected
    ↓
Identify affected architecture/features
    ↓
Create a short implementation plan
    ↓
Implement the smallest coherent change
    ↓
Test
    ↓
Review changes
```

For very small, obvious changes, a separate written plan is not
necessary.

### Rules

-   Do not explore unrelated parts of the project.
-   Do not modify files that are unrelated to the requested task.
-   Do not turn a small task into a broad refactor.
-   If a task requires changing an architectural rule, explain the
    impact before making that change.

------------------------------------------------------------------------

# 34. AI Permissions & Human Approval

PAYAYAR is user-owned software. The AI coding agent is an implementation
assistant, not the owner of product decisions.

### AI may

-   Analyze the existing code.
-   Suggest improvements.
-   Generate implementation code.
-   Refactor when necessary for the requested feature.
-   Run tests and diagnose errors.
-   Prepare validated AI suggestions for the application.

### AI must not silently

-   Change the product architecture.
-   Delete user data.
-   Change database schema in a destructive way.
-   Add a backend/cloud service.
-   Replace the selected technology stack.
-   Remove existing features.
-   Change major navigation.
-   Change the product scope.
-   Change the visual identity.
-   Send unrelated user data to an AI provider.
-   Execute arbitrary AI-generated code or SQL.

### AI-generated application actions

AI may propose changes to the user's plans, schedules, or records, but
important changes must follow:

``` text
AI suggestion
    ↓
Validate
    ↓
Show user what will change
    ↓
User approval when required
    ↓
Apply
    ↓
Verify
```

The AI must never treat its own suggestion as automatic authorization.

------------------------------------------------------------------------

# 35. Git, Backup & Reversible Changes

The project should remain easy to recover after AI-generated changes.

### Rules

Before significant changes, the agent should:

-   Inspect the current Git status.
-   Avoid overwriting unrelated user changes.
-   Keep changes focused and reviewable.
-   Avoid destructive commands unless explicitly authorized.

### Database safety

Before destructive database migrations or data transformations:

-   Preserve existing user data.
-   Use a migration strategy.
-   Validate the result.
-   Provide a recovery path where technically appropriate.

Never use:

``` text
Delete database
→ recreate database
```

as a shortcut for a schema change when existing user data may exist.

### Reversibility

Prefer changes that can be reverted cleanly.

Do not perform broad automatic cleanup merely to make the code look
cleaner.

------------------------------------------------------------------------

# 36. AI Failure Must Not Break the Application

PAYAYAR must remain usable when the AI service is unavailable.

Possible AI failures include:

-   Missing API key
-   Invalid API key
-   Network failure
-   Provider outage
-   Rate limit
-   Timeout
-   Malformed response
-   Invalid structured output
-   Unexpected model behavior

### Required behavior

-   Core local features must continue working.
-   The user must receive a clear, non-technical error state.
-   Existing local data must remain available.
-   AI failure must not corrupt the database.
-   AI failure must not block normal planning, studying, logging, or
    reporting.

AI is an enhancement to PAYAYAR, not a single point of failure.

------------------------------------------------------------------------

# 37. Context Minimization & Data Privacy

When sending information to an external AI API, send only the context
required for the requested task.

### Prefer

``` text
Requested task
+
Relevant records
+
Relevant current screen/context
```

### Avoid

``` text
Entire database
+
All historical records
+
Unrelated lifestyle data
+
Unrelated notes
+
Unrelated exams
```

### Rules

-   Do not send unrelated personal data to an AI provider.
-   Do not silently expand the AI context.
-   Do not upload the SQLite database as a shortcut.
-   Keep API keys local and protected.
-   Never hard-code a user's API key into source code.
-   Never commit API keys or secrets to Git.

------------------------------------------------------------------------

# 38. Functional Testing & Definition of Done

A feature is not complete merely because the project compiles.

### Relevant verification should include:

``` text
Build
  ↓
Relevant functional tests
  ↓
Database/data checks when applicable
  ↓
UI test when applicable
  ↓
Visual test when applicable
  ↓
Final review
```

The scope of testing should match the change.

### Definition of Done

A significant feature is complete when:

-   [ ] Requested behavior works
-   [ ] Existing relevant behavior still works
-   [ ] No build errors remain
-   [ ] Relevant tests pass
-   [ ] Database integrity is preserved
-   [ ] No unnecessary dependency was introduced
-   [ ] Architecture rules were preserved
-   [ ] `design.md` was followed when UI changed
-   [ ] Windows behavior was checked when relevant
-   [ ] Android behavior was checked when relevant
-   [ ] AI behavior was validated when relevant
-   [ ] No unrelated redesign/refactor was introduced

------------------------------------------------------------------------

# 39. Overengineering Guardrail

PAYAYAR is intentionally a small, local-first student application.

### Principle

> Simple first. Complexity must have a reason.

Do not introduce:

-   Microservices
-   Backend infrastructure
-   Cloud databases
-   Complex agent frameworks
-   Large state-management systems without need
-   Multiple unnecessary abstraction layers
-   Event buses without a concrete requirement
-   Heavy UI libraries for cosmetic effects
-   Complex synchronization systems
-   Infrastructure for hypothetical future requirements

### Decision rule

Before adding a major dependency or architectural layer, ask:

1.  What concrete current requirement needs it?
2.  Can the existing stack solve it?
3.  What complexity does it add?
4.  What maintenance cost does it create?
5.  Can a smaller solution solve the same problem?

Do not build infrastructure for problems that do not yet exist.

------------------------------------------------------------------------

# 40. Architecture Decision Records

Significant architecture decisions should be documented when useful.

For major decisions, prefer a small record containing:

``` text
Decision
Why it was needed
Alternatives considered
Chosen approach
Consequences
```

Possible location:

``` text
docs/decisions/
```

Do not create decision records for trivial implementation details.

The purpose is to prevent future AI agents from repeatedly reopening
settled architecture decisions without new evidence.

------------------------------------------------------------------------

# 41. Change Review Protocol

Before finishing a significant task, the agent should review its own
changes.

### Review questions

-   Did I modify only what was necessary?
-   Did I introduce a new dependency?
-   Did I change architecture unnecessarily?
-   Did I alter database behavior?
-   Could existing user data be affected?
-   Did I change unrelated UI?
-   Did I preserve Windows and Android behavior?
-   Did I preserve Persian and English support?
-   Did I preserve Dark and Light themes?
-   Did I expose additional data to AI?
-   Did I create a new pattern when an existing one could be reused?
-   Can the change be easily reverted?

If an answer reveals an unnecessary change, simplify the implementation
before finishing.

------------------------------------------------------------------------

# 42. Final Project Safety Gate

Before declaring a major task complete:

-   [ ] `AGENTS.md` rules were followed
-   [ ] `design.md` was read if UI was affected
-   [ ] Project stack was not changed without approval
-   [ ] No unnecessary infrastructure was introduced
-   [ ] No user data was deleted
-   [ ] Database changes are safe
-   [ ] AI output is validated
-   [ ] AI cannot silently perform important user actions
-   [ ] Only relevant context is sent to external AI APIs
-   [ ] API keys/secrets are not exposed or committed
-   [ ] Relevant tests were run
-   [ ] Existing functionality was checked
-   [ ] The change is reasonably reversible
-   [ ] No unrelated refactoring was introduced
-   [ ] The application remains useful when AI is unavailable

**Preserve product intent, user data, user control, and architectural
simplicity before optimizing implementation details.**

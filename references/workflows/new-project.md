# NEW_PROJECT Workflow

1. Codex inspects the target path and searches relevant project memory.
2. Codex records conservative assumptions and initial acceptance criteria.
3. Delegate planning to `oc-project-planner`.
4. Delegate architecture to the available architecture agent.
5. Codex approves milestone 1.
6. Delegate milestone 1 to the available builder or implementer agent.
7. Delegate independent review.
8. Delegate executable verification.
9. Delegate documentation synchronization to `oc-documenter`.
10. Codex accepts the milestone or returns exact evidence for repair.
11. Repeat by milestone.
12. Update `final.md` and project memory only from verified evidence.

Required project control files:

- `spec.md`
- `plan.md`
- `todos.md`
- `test.md`
- `final.md`

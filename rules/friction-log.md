# Friction Log

Apply only where the install opted in to the friction log, when a coding rule or an `INSTALL.md` step was wrong, unclear enough that you had to guess, in conflict with the project's conventions, or not followed on purpose. Notes written at that moment keep what you actually saw, which feedback reconstructed later from commits loses.

- Log only those four cases. A rule you simply applied, even one that took effort, is not friction.
- Log when it happens, before moving on: one entry per event, added at the end of the log. Never edit an existing entry, even about the same friction; collecting the log merges them. In project mode other branches append too, so resolve a conflict in the log by keeping both sides.
- Before blaming a rule, check the claim when that is cheap: run the tool, reread the rule's exact wording, try the case. Name the cause you believe in — the rules, the project, or a tool (a linter, a framework, the agent tool) — and say what you checked.
- The log is `feedback.md` in the rules folder that the managed block names. In personal mode it serves every project, so name the project in each entry. If you can't write to it, put the entry in your handoff instead.
- Keep secrets, credentials and personal data out of entries, and quote code only as far as the friction needs: the log may be committed with the project, and its entries may be sent to the rules' owner.
- A reviewer subagent doesn't edit the log. It marks the findings where the rule rather than the change looks wrong, and the agent that asked for the review logs those it agrees with.
- Never send the log or open an issue from it. Collecting it is the user's decision, through Check in `INSTALL.md`.

Each entry:

```markdown
## YYYY-MM-DD: <rule file and section, or INSTALL.md section and step>

- Project: <name> (personal mode only)
- What happened: <what the rule or step said, and what you ran into>
- What you did instead: <...>
- Cause: rules | project | tool (<which>); <what you checked>
- Evidence: <files, commands, commit if there is one>
```

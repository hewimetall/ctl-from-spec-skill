# Subagent-driven development

The parent is the manager. It talks to the user. It does not implement, does not patch a worktree, and does not run a task because a batch came back short.

## Fan-out

Start SWE in a batch of 20, in parallel. One fresh SWE per task. The prompt contains that task's text, its acceptance criteria, the accepted spec paths, and the worktree. It does not contain another SWE's scratchpad.

Inside the task the SWE follows [tdd.md](tdd.md): a failing test, then the smallest change that passes.

If fewer than 20 tasks are ready, start those and no more. Do not start a 21st in the same batch. Do not keep one task in the manager turn.

Two SWE in one batch do not share a file. A task that shares the binary, the root command, a client package, or any file with a SWE already in the batch waits for the next fan-out.

## Fan-in

The batch reports to the manager. Each SWE reports what it changed, which tests it ran, and the result. The manager tells the user. The manager then delegates. It does not apply the fix itself.

1. Delegate a fresh reviewer per returned diff. The reviewer gets the task text, the base commit, the result commit, and `.agent/result/patch.diff`. It checks the diff against the accepted spec for the rows this task touches.
2. Critical issues are fixed before the next fan-out, by a new SWE that receives the review notes. Important issues are fixed before the next fan-out. Minor issues are recorded and do not block.
3. Append a transition line for this task in `docs/runtime/manifest.jsonl`. That line is not status `succeeded`.

Do not start the next batch while a Critical issue from this fan-in is open. A conflict, two SWE touching one file, sends those tasks into a later batch, still as delegated SWE.

## Final review

After the last fan-in, the manager delegates one reviewer for the whole CLI diff. The reviewer uses [judges.md](judges.md). The manager does not review the diff.

## Stop

Stop the run when a dependency is missing, a test keeps failing, or a plan step cannot be executed as written. Report the blocker. Do not invent the missing step.

If an SWE fails the task, the manager dispatches a fix SWE with the failing test and the review notes. The manager does not take over the edit.

# Project Tooling

Apply when adding or changing a project's linter, formatter, type checker or test runner, including when creating a project. An existing project's choices win.

- Adding a tool is the owner's decision. Propose what is missing, one recommendation per kind of tool with the reason it fits this project, and add only what the user accepts.
- Pick from "Choosing tools" in `docs/tooling.md`, and configure the settings that file lists for each tool you add. `docs/tooling.md` and `INSTALL.md` are in the coding-rules folder named in the instructions file.
- Expose every tool through a project script (`format`, `lint`, `typecheck`, `test`) that also takes file paths where the tool allows, so hooks, CI and people run the same commands.
- Once the tools work, wire the agent hooks that run them, following "Set up tooling" in `INSTALL.md`. Ask before writing a tool's settings file.
- When the project replaces a tool that existing hooks call, update the hooks in the same change.
- The setup is done when a hook has fired on a real edit, not when its configuration is written.

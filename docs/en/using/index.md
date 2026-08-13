<!-- section:s001 -->
# Using

This area is for users who have completed first connection and want a stable daily workflow across the handle, AutoClipboard, and AI Agents.

<!-- section:s002 -->
## Daily tasks

- [Daily-use workflow](daily-workflow.md)
- [Complete hardware and software manual](../user-guide.md)
- [AutoClipboard interface by region](../software-interface-manual.md)
- [Agent status synchronization setup](../agent-signal-setup.md)

<!-- section:s003 -->
## Three layers to distinguish

1. **HID input layer**: macros send keyboard shortcuts to the operating system and do not require AutoClipboard after connection.
2. **Device-control layer**: AutoClipboard uses status, command, and IMU characteristics to read state and change settings.
3. **Agent-workflow layer**: Codex, Claude Code, and similar clients use hooks to send work state to AutoClipboard and then the handle.

One working layer does not prove that the others work. Diagnose the failing layer first.

<!-- section:s004 -->
## Recommended habits

- Create separate Profiles for separate contexts instead of overloading one Profile.
- Test changed macros in a plain-text editor before using them in an IDE, terminal, or presentation tool.
- During multi-host switching, select the handle slot before operating the destination computer.
- Keep a settings snapshot before upgrades; application updates must preserve Profiles, launch targets, and personal settings.
- Enter Maintenance, Bluetooth repair, or firmware update only when the task explicitly requires it.

<!-- section:s005 -->
## Next steps

- Learn end-to-end scenarios: [Guides and Tutorials](../guides-and-tutorials/index.md)
- Understand feature design: [Features](../features/index.md)
- Look up status and compatibility: [Reference](../reference/index.md)

import { Plugin } from "@opencode/plugin/tui";
import { jsx } from "@opentui/solid/jsx-runtime";
import { createEffect, createRoot } from "solid-js";

export const define = (definition) =>
  Plugin.define({
    id: definition.id,
    setup: (context) => definition.setup(context)(),
  });

export const renderer = (context) => context.renderer;

export const cwd = (context) => () =>
  (context.location ?? context.data.location.default()).directory;

export const themeMode = (context) => () => context.themeMode;

export const mutedColor = (context) => () => context.theme.text.muted;

export const backgroundColor = (context) => () => context.theme.background.base;

export const route = (context) => () => {
  const current = context.ui.router.current();
  return {
    kind: current.type,
    sessionID: current.type === "session" ? current.sessionID : null,
  };
};

export const observeRoute = (context) => (callback) => () =>
  createRoot((dispose) => {
    createEffect(() => {
      context.ui.router.current();
      callback();
    });
    return dispose;
  });

export const registerCommand = (context) => (command) => (run) => () => {
  context.keymap.layer(() => ({
    mode: "global",
    commands: [
      {
        id: command.id,
        title: command.title,
        description: command.description,
        group: command.group,
        palette: true,
        slash: { name: command.name, arguments: true },
        run: (input) => run(input ?? null)(),
      },
    ],
  }));
};

export const mountSlot = (context) => (path) => (factory) => () =>
  context.ui.slot({
    append: path,
    render: (input) => jsx(() => factory(input.sessionID ?? null)()),
  });

export const pushMode = (context) => (mode) => () => context.keymap.mode.push(mode);

export const registerKeys = (context) => (renderable) => (mode) => (commands) => () => {
  context.keymap.layer(() => ({
    mode,
    target: () => renderable,
    priority: 100,
    commands: commands.map((command) => ({
      id: command.id,
      bind: command.bind,
      run: (_input, event) => {
        event?.preventDefault();
        event?.stopPropagation();
        command.run();
      },
    })),
  }));
};

export const notifyError = (context) => (message) => () => {
  context.ui.toast.show({ message, variant: "error" });
};

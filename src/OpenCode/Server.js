import { Plugin } from "@opencode/plugin";

export const define = (definition) =>
  Plugin.define({
    id: definition.id,
    setup: (context) =>
      definition.setup(context)().then((cleanup) => async () => {
        await cleanup();
      }),
  });

export const locationDirectory = (context) => () => context.location.directory;

export const registerTool = (context) => (tool) => () =>
  context.tool
    .transform((editor) => {
      editor.add({
        name: tool.name,
        description: tool.description,
        input: tool.inputSchema,
        execute: (input, execution) => tool.execute(input)(execution)(),
      });
    })
    .then((registration) => async () => {
      await registration.dispose();
    });

export const sessionId = (context) => context.sessionID;

export const onAbort = (context) => (callback) => () => {
  const signal = context.signal;
  let removed = false;
  const remove = () => {
    if (!removed) {
      removed = true;
      signal.removeEventListener("abort", listener);
    }
  };
  const listener = () => {
    remove();
    callback();
  };

  if (signal.aborted) listener();
  else signal.addEventListener("abort", listener, { once: true });
  return remove;
};

export const success = (message) => ({ content: message });

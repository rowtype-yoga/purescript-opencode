import { Rpc } from "@opencode/plugin";

export const define = (definition) =>
  Rpc.define({
    id: definition.id,
    methods: Object.fromEntries(
      definition.methods.map((method) => [
        method.name,
        { input: method.inputSchema, output: method.outputSchema },
      ]),
    ),
    events: Object.fromEntries(
      definition.events.map((event) => [event.name, { schema: event.schema }]),
    ),
  });

export const client = (context) => (contract) => () => ({
  rpc: context.client.rpc(contract),
  location: context.location ?? context.data.location.default(),
});

export const register = (context) => (contract) => (handlers) => () =>
  context.rpc.register(
    contract,
    Object.fromEntries(
      handlers.map((handler) => [
        handler.name,
        (input, context) => handler.handler(input)(context)(),
      ]),
    ),
  );

export const emit = (registration) => (name) => (data) => () =>
  registration.events.emit(name, data);

export const dispose = (registration) => () => registration.dispose();

export const callImpl = (client) => (name) => (input) => () => {
  const controller = new AbortController();
  return {
    promise: client.rpc[name](input, {
      location: client.location,
      signal: controller.signal,
    }),
    cancel: () => controller.abort(),
  };
};

export const listen = (rpc) => (name) => (handler) => () =>
  rpc.rpc.events.on(name, (event) => handler(event.data)());

let nativeRenderLibrary;
const textEncoder = new TextEncoder();

const renderLibrary = () => {
  nativeRenderLibrary ??= resolveRenderLib();
  return nativeRenderLibrary;
};

const subscribe = (target, event, callback) => () => {
  const listener = () => callback();
  target.on(event, listener);
  return () => target.off(event, listener);
};

export const createBox = renderer => options => renderAfter => () => {
  const renderable = new BoxRenderable(renderer, {
    width: options.width,
    height: options.height,
    flexShrink: options.flexShrink,
    backgroundColor: options.backgroundColor,
    renderAfter(buffer) {
      renderAfter(this)(buffer)();
    },
  });
  renderable.focusable = options.focusable;
  return renderable;
};

export const metrics = renderer => () => {
  const resolution = renderer.resolution;
  return {
    columns: renderer.terminalWidth,
    rows: renderer.terminalHeight,
    width: renderer.width,
    height: renderer.height,
    resolution: resolution === null ? null : {
      width: resolution.width,
      height: resolution.height,
    },
  };
};

export const bounds = renderable => () => ({
  x: renderable.screenX,
  y: renderable.screenY,
  width: renderable.width,
  height: renderable.height,
  visible: renderable.visible,
  destroyed: renderable.isDestroyed,
  focused: renderable.focused,
});

export const capabilities = renderer => () => {
  const terminalCapabilities = renderer.capabilities;
  return terminalCapabilities === null ? null : {
    kittyGraphics: terminalCapabilities.kitty_graphics,
    rgb: terminalCapabilities.rgb,
    remote: terminalCapabilities.remote,
    multiplexer: terminalCapabilities.multiplexer !== "none",
  };
};

export const controlState = renderer => () => renderer.controlState;

export const isDestroyed = renderer => () => renderer.isDestroyed;

export const focused = renderer => () => renderer.currentFocusedRenderable;

export const focus = renderable => () => {
  renderable.focus();
};

export const blur = renderable => () => {
  renderable.blur();
};

export const setHeight = renderable => height => () => {
  renderable.height = height;
};

export const requestRender = renderer => () => {
  renderer.requestRender();
};

export const writeControl = renderer => control => () => {
  renderLibrary().writeOut(renderer.rendererPtr, textEncoder.encode(control));
};

export const prependInputHandler = renderer => callback => () => {
  const handler = sequence => callback(sequence)();
  renderer.prependInputHandler(handler);
  return () => renderer.removeInputHandler(handler);
};

export const onFrame = renderer => callback => subscribe(renderer, "frame", callback);

export const onResize = renderer => callback => subscribe(renderer, "resize", callback);

export const onRendererDestroy = renderer => callback => subscribe(renderer, "destroy", callback);

export const onDestroyed = renderable => callback => subscribe(renderable, "destroyed", callback);

export const rgba = red => green => blue => alpha => RGBA.fromInts(red, green, blue, alpha);

export const drawText = buffer => text => x => y => foreground => background => () => {
  buffer.drawText(text, x, y, foreground, background, 0);
};

export const pushScissor = buffer => rect => () => {
  buffer.pushScissorRect(rect.x, rect.y, rect.width, rect.height);
};

export const popScissor = buffer => () => {
  buffer.popScissorRect();
};

import { BoxRenderable, RGBA, resolveRenderLib } from "@opentui/core";

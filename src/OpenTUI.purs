module OpenTUI
  ( Renderer
  , Renderable
  , Buffer
  , Color
  , Metrics
  , Bounds
  , Capabilities
  , BoxOptions
  , createBox
  , metrics
  , bounds
  , capabilities
  , controlState
  , isDestroyed
  , focused
  , focus
  , blur
  , setHeight
  , requestRender
  , writeControl
  , prependInputHandler
  , onFrame
  , onResize
  , onRendererDestroy
  , onDestroyed
  , rgba
  , drawText
  , pushScissor
  , popScissor
  ) where

import Prelude

import Data.Nullable (Nullable)
import Effect (Effect)

type Metrics =
  { columns :: Int
  , rows :: Int
  , width :: Int
  , height :: Int
  , resolution :: Nullable { width :: Number, height :: Number }
  }

type Bounds =
  { x :: Int
  , y :: Int
  , width :: Int
  , height :: Int
  , visible :: Boolean
  , destroyed :: Boolean
  , focused :: Boolean
  }

type Capabilities =
  { kittyGraphics :: Boolean
  , rgb :: Boolean
  , remote :: Boolean
  , multiplexer :: Boolean
  }

type BoxOptions =
  { width :: String
  , height :: Int
  , flexShrink :: Int
  , backgroundColor :: String
  , focusable :: Boolean
  }

foreign import data Renderer :: Type

foreign import data Renderable :: Type

foreign import data Buffer :: Type

foreign import data Color :: Type

foreign import createBox :: Renderer -> BoxOptions -> (Renderable -> Buffer -> Effect Unit) -> Effect Renderable

foreign import metrics :: Renderer -> Effect Metrics

foreign import bounds :: Renderable -> Effect Bounds

foreign import capabilities :: Renderer -> Effect (Nullable Capabilities)

foreign import controlState :: Renderer -> Effect String

foreign import isDestroyed :: Renderer -> Effect Boolean

foreign import focused :: Renderer -> Effect (Nullable Renderable)

foreign import focus :: Renderable -> Effect Unit

foreign import blur :: Renderable -> Effect Unit

foreign import setHeight :: Renderable -> Int -> Effect Unit

foreign import requestRender :: Renderer -> Effect Unit

foreign import writeControl :: Renderer -> String -> Effect Unit

foreign import prependInputHandler :: Renderer -> (String -> Effect Boolean) -> Effect (Effect Unit)

foreign import onFrame :: Renderer -> Effect Unit -> Effect (Effect Unit)

foreign import onResize :: Renderer -> Effect Unit -> Effect (Effect Unit)

foreign import onRendererDestroy :: Renderer -> Effect Unit -> Effect (Effect Unit)

foreign import onDestroyed :: Renderable -> Effect Unit -> Effect (Effect Unit)

foreign import rgba :: Int -> Int -> Int -> Int -> Color

foreign import drawText :: Buffer -> String -> Int -> Int -> Color -> Color -> Effect Unit

foreign import pushScissor :: Buffer -> { x :: Int, y :: Int, width :: Int, height :: Int } -> Effect Unit

foreign import popScissor :: Buffer -> Effect Unit

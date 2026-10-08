module OpenCode.TUI
  ( Context
  , Plugin
  , Route
  , define
  , renderer
  , cwd
  , themeMode
  , mutedColor
  , backgroundColor
  , route
  , observeRoute
  , registerCommand
  , mountSlot
  , pushMode
  , registerKeys
  , notifyError
  ) where

import Data.Nullable (Nullable)
import Effect (Effect)
import Promise (Promise)
import OpenTUI (Color, Renderable, Renderer)
import Prelude (Unit)

type Route =
  { kind :: String
  , sessionID :: Nullable String
  }

foreign import data Context :: Type

foreign import data Plugin :: Type

-- The host owns setup invocation and calls the cleanup effect returned by setup.
foreign import define
  :: { id :: String, setup :: Context -> Effect (Effect Unit) }
  -> Plugin

foreign import renderer :: Context -> Renderer

foreign import cwd :: Context -> Effect String

foreign import themeMode :: Context -> Effect String

foreign import mutedColor :: Context -> Effect Color

foreign import backgroundColor :: Context -> Effect Color

foreign import route :: Context -> Effect Route

-- The callback runs immediately and on later route changes. Run the returned cleanup
-- to dispose its Solid root.
foreign import observeRoute :: Context -> Effect Unit -> Effect (Effect Unit)

foreign import registerCommand
  :: Context
  -> { id :: String
     , title :: String
     , description :: String
     , group :: String
     , name :: String
     }
  -> (Nullable String -> Effect (Promise Unit))
  -> Effect Unit

-- The returned cleanup unregisters the host slot claim. The slot callback creates
-- the renderable and owns resources associated with it.
foreign import mountSlot
  :: Context
  -> String
  -> (Nullable String -> Effect (Nullable Renderable))
  -> Effect (Effect Unit)

-- Run the returned cleanup to pop precisely this mode stack entry.
foreign import pushMode :: Context -> String -> Effect (Effect Unit)

foreign import registerKeys
  :: Context
  -> Renderable
  -> String
  -> Array { id :: String, bind :: String, run :: Effect Unit }
  -> Effect Unit

foreign import notifyError :: Context -> String -> Effect Unit

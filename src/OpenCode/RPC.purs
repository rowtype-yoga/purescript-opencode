module OpenCode.RPC
  ( Client
  , Contract
  , CallContext
  , Registration
  , Method
  , Event
  , Handler
  , define
  , client
  , register
  , emit
  , dispose
  , call
  , listen
  ) where

import Prelude

import Effect (Effect)
import Effect.Aff (Aff, bracket)
import Effect.Class (liftEffect)
import Foreign (Foreign)
import OpenCode.Server (Context)
import OpenCode.TUI (Context) as TUI
import Promise (Promise)
import Promise.Aff as Promise

type Handler = Foreign -> CallContext -> Effect (Promise Foreign)

type Method =
  { name :: String
  , inputSchema :: Foreign
  , outputSchema :: Foreign
  }

type Event =
  { name :: String
  , schema :: Foreign
  }

call :: Client -> String -> Foreign -> Aff Foreign
call connection name input =
  bracket (liftEffect (callImpl connection name input))
    (liftEffect <<< _.cancel)
    (Promise.toAff <<< _.promise)

foreign import data Client :: Type

foreign import data Contract :: Type

foreign import data CallContext :: Type

foreign import data Registration :: Type

-- | Definitions contain only portable Standard Schema/JSON Schema values.
foreign import define
  :: { id :: String
     , methods :: Array Method
     , events :: Array Event
     }
  -> Contract

foreign import client :: TUI.Context -> Contract -> Effect Client

foreign import register
  :: Context
  -> Contract
  -> Array { name :: String, handler :: Handler }
  -> Effect (Promise Registration)

foreign import emit
  :: Registration
  -> String
  -> Foreign
  -> Effect (Promise Unit)

foreign import dispose :: Registration -> Effect (Promise Unit)

foreign import listen
  :: Client
  -> String
  -> (Foreign -> Effect Unit)
  -> Effect (Effect Unit)

foreign import callImpl
  :: Client
  -> String
  -> Foreign
  -> Effect { promise :: Promise Foreign, cancel :: Effect Unit }

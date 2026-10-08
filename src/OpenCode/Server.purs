module OpenCode.Server
  ( Context
  , Plugin
  , ToolContext
  , ToolResult
  , Tool
  , define
  , locationDirectory
  , registerTool
  , sessionId
  , onAbort
  , success
  ) where

import Effect (Effect)
import Foreign (Foreign)
import Promise (Promise)
import Prelude (Unit)

-- | Schemas are Standard Schema or JSON Schema values supplied by the caller.
-- | Keeping them Foreign lets applications choose their JSON codec without
-- | making this SDK binding own application schemas.
type Tool =
  { name :: String
  , description :: String
  , inputSchema :: Foreign
  , execute :: Foreign -> ToolContext -> Effect (Promise ToolResult)
  }

foreign import data Context :: Type

foreign import data Plugin :: Type

foreign import data ToolContext :: Type

foreign import data ToolResult :: Type

-- | The cleanup returned from setup is asynchronous because OpenCode tool and
-- | RPC registrations have asynchronous disposal.
foreign import define
  :: { id :: String
     , setup :: Context -> Effect (Promise (Effect (Promise Unit)))
     }
  -> Plugin

-- | The location is the server plugin instance's location, not process.cwd().
foreign import locationDirectory :: Context -> Effect String

foreign import registerTool
  :: Context
  -> Tool
  -> Effect (Promise (Effect (Promise Unit)))

foreign import sessionId :: ToolContext -> String

-- | Registers one AbortSignal listener and returns its idempotent removal.
foreign import onAbort
  :: ToolContext
  -> Effect Unit
  -> Effect (Effect Unit)

foreign import success :: String -> ToolResult

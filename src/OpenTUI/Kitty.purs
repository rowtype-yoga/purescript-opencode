module OpenTUI.Kitty
  ( SharedImage
  , Reply
  , transmit
  , placement
  , deleteImage
  , placeholderRows
  , reply
  ) where

import Prelude

import Data.Array as Array
import Data.Int as Int
import Data.Maybe (Maybe(..))
import Data.String as String
import Data.String.CodePoints as CodePoints

type SharedImage =
  { width :: Int
  , height :: Int
  , byteLength :: Int
  , encodedName :: String
  }

type Reply =
  { imageId :: Int
  , placementId :: Maybe Int
  , message :: String
  }

apcPrefix :: String
apcPrefix = "\x1b_G"

apcSuffix :: String
apcSuffix = "\x1b\\"

placeholderCharacter :: String
placeholderCharacter = "􎻮"

maximumImageId :: Int
maximumImageId = 2147483647

maximumGeometry :: Int
maximumGeometry = 297

highByteDivisor :: Int
highByteDivisor = 16777216

-- Source: kitty's normative rowcolumn-diacritics.txt table,
-- https://sw.kovidgoyal.net/kitty/_downloads/f0a0de9ec8d9ff4456206db8e0814937/rowcolumn-diacritics.txt
-- The table has 297 entries; it is converted once when this module initializes.
diacritics :: Array String
diacritics = map CodePoints.singleton (CodePoints.toCodePointArray "̅̍̎̐̒̽̾̿͆͊͋͌͐͑͒͗͛ͣͤͥͦͧͨͩͪͫͬͭͮͯ҃҄҅҆҇֒֓֔֕֗֘֙֜֝֞֟֠֡֨֩֫֬֯ׄؐؑؒؓؔؕؖؗٗ٘ٙٚٛٝٞۖۗۘۙۚۛۜ۟۠ۡۢۤۧۨ۫۬ܰܲܳܵܶܺܽܿ݀݁݃݅݇݉݊߫߬߭߮߯߰߱߳ࠖࠗ࠘࠙ࠛࠜࠝࠞࠟࠠࠡࠢࠣࠥࠦࠧࠩࠪࠫࠬ࠭॑॓॔ྂྃ྆྇፝፞፟៝᤺ᨗ᩵᩶᩷᩸᩹᩺᩻᩼᭫᭭᭮᭯᭰᭱᭲᭳᳐᳑᳒᳚᳛᳠᷀᷁᷃᷄᷅᷆᷇᷈᷉᷋᷌᷑᷒ᷓᷔᷕᷖᷗᷘᷙᷚᷛᷜᷝᷞᷟᷠᷡᷢᷣᷤᷥᷦ᷾⃐⃑⃔⃕⃖⃗⃛⃜⃡⃧⃩⃰⳯⳰⳱ⷠⷡⷢⷣⷤⷥⷦⷧⷨⷩⷪⷫⷬⷭⷮⷯⷰⷱⷲⷳⷴⷵⷶⷷⷸⷹⷺⷻⷼⷽⷾⷿ꙯꙼꙽꛰꛱꣠꣡꣢꣣꣤꣥꣦꣧꣨꣩꣪꣫꣬꣭꣮꣯꣰꣱ꪰꪲꪳꪷꪸꪾ꪿꫁︠︡︢︣︤︥︦𐨏𐨸𝆅𝆆𝆇𝆈𝆉𝆪𝆫𝆬𝆭𝉂𝉃𝉄")

apc :: String -> String -> String
apc controlData payload = apcPrefix <> controlData <> ";" <> payload <> apcSuffix

validImageId :: Int -> Boolean
validImageId imageId = imageId > 0 && imageId <= maximumImageId

validSharedImage :: SharedImage -> Boolean
validSharedImage image =
  image.width > 0
    && image.height > 0
    && image.byteLength > 0

cappedGeometry :: Int -> Int
cappedGeometry count = min maximumGeometry count

transmit :: Int -> Int -> Int -> SharedImage -> String
transmit imageId columns rows image
  | validImageId imageId && columns > 0 && rows > 0 && validSharedImage image =
      apc
        ( "a=t,f=32,t=s,q=0,i=" <> show imageId
            <> ",s="
            <> show image.width
            <> ",v="
            <> show image.height
            <> ",S="
            <> show image.byteLength
        )
        image.encodedName
        <> apc
          ( "a=p,U=1,q=2,i=" <> show imageId
              <> ",p=1,c="
              <> show (cappedGeometry columns)
              <> ",r="
              <> show (cappedGeometry rows)
          )
          ""
  | otherwise = ""

placement :: Int -> Int -> Int -> String
placement imageId columns rows
  | validImageId imageId && columns > 0 && rows > 0 =
      apc
        ( "a=p,U=1,q=0,i=" <> show imageId
            <> ",p=1,c="
            <> show (cappedGeometry columns)
            <> ",r="
            <> show (cappedGeometry rows)
        )
        ""
  | otherwise = ""

deleteImage :: Int -> String
deleteImage imageId
  | validImageId imageId = apc ("a=d,d=I,i=" <> show imageId <> ",q=2") ""
  | otherwise = ""

diacritic :: Int -> String
diacritic index = case Array.index diacritics index of
  Just mark -> mark
  Nothing -> ""

placeholderCell :: Int -> Int -> Int -> String
placeholderCell row column highByte =
  placeholderCharacter
    <> diacritic row
    <> diacritic column
    <> diacritic highByte

placeholderRows :: Int -> Int -> Int -> Array String
placeholderRows imageId columns rows
  | not (validImageId imageId) = []
  | columns <= 0 || rows <= 0 = []
  | otherwise =
      let
        columnCount = cappedGeometry columns
        rowCount = cappedGeometry rows
        highByte = imageId / highByteDivisor
        rowString row = Array.foldMap (\column -> placeholderCell row column highByte) (Array.range 0 (columnCount - 1))
      in
        map rowString (Array.range 0 (rowCount - 1))

controlValue :: String -> String -> Maybe String
controlValue key =
  Array.findMap (String.stripPrefix (String.Pattern (key <> "=")))
    <<< String.split (String.Pattern ",")

positiveInt :: String -> Maybe Int
positiveInt value = case Int.fromString value of
  Just number | number > 0 -> Just number
  _ -> Nothing

reply :: String -> Maybe Reply
reply input = do
  withoutPrefix <- String.stripPrefix (String.Pattern apcPrefix) input
  body <- String.stripSuffix (String.Pattern apcSuffix) withoutPrefix
  if String.contains (String.Pattern apcPrefix) body || String.contains (String.Pattern apcSuffix) body then Nothing
  else do
    separator <- String.indexOf (String.Pattern ";") body
    let controlData = String.take separator body
    let message = String.drop (separator + 1) body
    imageId <- controlValue "i" controlData >>= positiveInt
    placementId <- case controlValue "p" controlData of
      Nothing -> Just Nothing
      Just value -> Just <$> Int.fromString value
    pure { imageId, placementId, message }

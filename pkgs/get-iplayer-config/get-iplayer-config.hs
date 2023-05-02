#! /usr/bin/env nix-shell
#! -*- mode: haskell -*-
#! nix-shell -i runghc -p myHaskellEnv

-- Nice additions to Tfmt to add:
--   - '%?\w' - meaning 'Maybe \w', if it's null, print nothing
-- FromJSON of absfile, etc.

{-# LANGUAGE DeriveAnyClass    #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE TemplateHaskell   #-}

import Prelude ( error )

-- aeson -------------------------------

import Data.Aeson.Types  ( Value( String ), defaultOptions
                         , fieldLabelModifier, genericParseJSON, typeMismatch )

-- base --------------------------------

import Control.Monad        ( forM_, return )
import Data.Either          ( either )
import Data.Function        ( (.), ($), id )
import Data.Maybe           ( Maybe, maybe )    
import Data.Monoid          ( (<>) )
import Data.String          ( String )
import GHC.Generics         ( Generic )
import System.IO            ( IO )
import Text.Show            ( Show, show )

-- data-textual ------------------------

import Data.Textual  ( Printable( print ), toText )

-- fluffy ------------------------------

import Fluffy.Functor  ( (>>$) )
import Fluffy.Options  ( optParser, textArgument )
import Fluffy.Path     ( AbsDir, parseAbsDir_ )

-- lens --------------------------------

import Control.Lens     ( (^.) )
import Control.Lens.TH  ( makeLenses )

-- optparse-applicative ----------------

import Options.Applicative.Builder  ( metavar )

-- text --------------------------------

import Data.Text     ( Text, pack, unpack )
import Data.Text.IO  ( putStrLn )

-- text-printer ------------------------

import qualified Text.Printer  as  P

-- tfmt --------------------------------

import Text.Fmt  ( fmt )

-- yaml --------------------------------

import Data.Yaml  ( FromJSON( parseJSON ), decodeFileEither )

--------------------------------------------------------------------------------

newtype Search = Search Text
  deriving (FromJSON, Generic, Show)

instance Printable Search where
  print (Search t) = P.text t

------------------------------------------------------------

data SearchType = TV | Radio
  deriving (FromJSON, Generic, Show)

instance Printable SearchType where
  print TV    = P.text "tv"
  print Radio = P.text "radio"

------------------------------------------------------------

newtype Channel = Channel { unChannel :: Text }
  deriving (Generic, Show)

instance FromJSON Channel where
  parseJSON (String t) = return $ Channel t
  parseJSON invalid    = typeMismatch "Channel" invalid

------------------------------------------------------------

data SearchConfig = SearchConfig { _search     :: Search
                                 , _searchType :: SearchType
                                 , _channel    :: Maybe Channel
                                 }
  deriving (Generic, Show)

flm' :: String -> String
flm' "_searchType" = "type"
flm' ('_' : x)     = x
flm' y             = y

instance FromJSON SearchConfig where
  parseJSON = genericParseJSON (defaultOptions { fieldLabelModifier = flm' })

instance Printable SearchConfig where
  print (SearchConfig s t c) =
    P.text $ [fmt|search0 %T\ntype %T%t|] s t (maybe "" (("\nchannel " <>) . unChannel) c)

------------------------------------------------------------

newtype MyAbsDir = MyAbsDir AbsDir
  deriving Show

instance FromJSON MyAbsDir where
  parseJSON (String t) = return $ MyAbsDir (parseAbsDir_ t)
  parseJSON invalid = typeMismatch "AbsDir" invalid

------------------------------------------------------------

data Config = Config { _output   :: MyAbsDir
                     , _searches :: [SearchConfig] }
  deriving (Generic, Show)

$( makeLenses ''Config )

flm :: String -> String
flm ('_' : x)     = x
flm y             = y

instance FromJSON Config where
  parseJSON = genericParseJSON (defaultOptions { fieldLabelModifier = flm })

------------------------------------------------------------

writeSearchConfigs :: [SearchConfig] -> IO ()
writeSearchConfigs ss = forM_ ss (putStrLn . toText)

main :: IO ()
main = do
  ymlfn <- optParser "write get_iplayer configuration"
                     (textArgument (metavar "searches.yml") )
  config <- (decodeFileEither (unpack ymlfn)) >>$ either (error . show) id
  putStrLn . pack . show $ config ^. output
  writeSearchConfigs (config ^. searches)

-- that's all, folks! ----------------------------------------------------------

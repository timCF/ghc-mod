module CradleSpec where

import Control.Applicative
import Language.Haskell.GhcMod
import System.Directory (canonicalizePath)
import System.FilePath ((</>))
import Test.Hspec

import Dir

spec :: Spec
spec = do
    describe "findCradle" $ do
        it "returns the current directory" $ do
            withDirectory_ "/" $ do
                curDir <- canonicalizePath "/"
                res <- findCradle
                res `shouldBe` Cradle {
                    cradleCurrentDir = curDir
                  , cradleCabalDir = Nothing
                  , cradleCabalFile = Nothing
                  , cradlePackageConf = Nothing
                  }

        it "finds a cabal file and a sandbox" $ do
            withDirectory "test/data/subdir1/subdir2" $ \dir -> do
                res <- relativeCradle dir <$> findCradle
                res `shouldBe` Cradle {
                    cradleCurrentDir = "test" </> "data" </> "subdir1" </> "subdir2"
                  , cradleCabalDir = Just ("test" </> "data")
                  , cradleCabalFile = Just ("test" </> "data" </> "cabalapi.cabal")
                  , cradlePackageConf = Just ("test" </> "data" </> ".cabal-sandbox" </> "i386-osx-ghc-7.6.3-packages.conf.d")
                  }

relativeCradle :: FilePath -> Cradle -> Cradle
relativeCradle dir cradle = Cradle {
    cradleCurrentDir  = toRelativeDir dir  $  cradleCurrentDir  cradle
  , cradleCabalDir    = toRelativeDir dir <$> cradleCabalDir    cradle
  , cradleCabalFile   = toRelativeDir dir <$> cradleCabalFile   cradle
  , cradlePackageConf = toRelativeDir dir <$> cradlePackageConf cradle
  }

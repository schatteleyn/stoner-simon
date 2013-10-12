--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll
import		 Data.Functor ((<$>))

--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do
    
    tags <- buildTags "posts/*" (fromCapture "tags/*.html")
    
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match (fromList ["about.rst", "contact.markdown"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
	    >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls


    match "index.html" $ do
        route idRoute
        compile $ do
	    posts <- loadAll "posts/*"
            sorted <- take 10 <$> recentFirst posts
            let indexCtx = 
                    listField "posts" postCtx (return sorted) `mappend`
                    constField "title" "Archives"            `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match (fromList [ "links.markdown" ]) $ do
      route   $ setExtension "html"
      compile $ pandocCompiler
        >>= loadAndApplyTemplate "templates/default.html" defaultContext
        >>= relativizeUrls

    create ["atom.xml"] $ do
        route idRoute
        compile $ do
	    posts <- loadAllSnapshots "posts/*" "content"
            sorted <- take 10 <$> recentFirst posts
	    renderAtom feedConfiguration feedCtx sorted

    create ["rss.xml"] $ do
        route idRoute
        compile $ do
	    posts <- loadAllSnapshots "posts/*" "content"
            sorted <- take 10 <$> recentFirst posts
	    renderRss feedConfiguration feedCtx sorted

    match "templates/*" $ compile templateCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

feedCtx :: Context String
feedCtx = bodyField "description" `mappend`
    postCtx

feedConfiguration :: FeedConfiguration
feedConfiguration = FeedConfiguration
    { feedTitle       = "Stoner Simon"
    , feedDescription = "Sharing stoner along the web"
    , feedAuthorName  = "Simon"
    , feedAuthorEmail = ""
    , feedRoot        = "http://schatteleyn.github.io/stoner-simon"
    }

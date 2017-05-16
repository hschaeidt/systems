module Main (main) where

import XMonad

import Graphics.X11.Xlib
import XMonad.Prompt.Pass
import qualified Data.Map as M

main :: IO ()
main = xmonad $ def
      { modMask = mod4Mask  -- super instead of alt (usually Windows key)
      , terminal = "urxvt"
      , keys = myKeys <+> keys def
      }

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList
    [ ((modm , xK_p)                              , passPrompt def)
    , ((modm .|. controlMask, xK_p)               , passGeneratePrompt def)
    , ((modm .|. controlMask  .|. shiftMask, xK_p), passRemovePrompt def)

    -- lock the screen with xscreensaver
    , ((modm .|. shiftMask, xK_l), spawn "xset +dpms && scrot /tmp/screen_locked.png && convert /tmp/screen_locked.png -blur 0x3 /tmp/screen_locked2.png && i3lock -i /tmp/screen_locked2.png")

    -- program launcher key bindings
    , ((modm .|. shiftMask, xK_f), spawn "firefox")
    , ((modm .|. shiftMask, xK_p), spawn "code")
    ]

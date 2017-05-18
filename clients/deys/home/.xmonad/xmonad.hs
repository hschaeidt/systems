module Main (main) where

import XMonad

import XMonad.Prompt.Pass
import qualified Data.Map as M
import XMonad.Util.Run
import XMonad.Hooks.ManageDocks

main :: IO ()
main = do
  xmobar <- spawnPipe "xmobar ~/.config/xmobar/xmobarrc"
  xmonad $ def
    { modMask = mod4Mask  -- super instead of alt (usually Windows key)
    , manageHook         = manageDocks <+> manageHook def
    , layoutHook         = avoidStruts $ layoutHook def
    , handleEventHook    = handleEventHook def <+> docksEventHook
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

--
-- xmonad example config file for xmonad-0.9
--
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you'd only override those defaults you care about.
--
-- NOTE: Those updating from earlier xmonad versions, who use
-- EwmhDesktops, safeSpawn, WindowGo, or the simple-status-bar
-- setup functions (dzen, xmobar) probably need to change
-- xmonad.hs, please see the notes below, or the following
-- link for more details:
--
-- http://www.haskell.org/haskellwiki/Xmonad/Notable_changes_since_0.8
--
import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.WorkspaceCompare
import XMonad.Util.Loggers
import XMonad.Layout.NoBorders(smartBorders)
import XMonad.Layout.LayoutCombinators hiding ( (|||) )
import XMonad.Actions.WindowBringer
import Data.Monoid
import System.Exit
import System.IO
import Graphics.X11.ExtraTypes.XF86

import qualified XMonad.StackSet as W
import qualified Data.Map        as M
 
-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal      = "urxvt"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True
 
-- Width of the window border in pixels.
--
myBorderWidth   = 1
 
-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod4Mask
 
-- NOTE: from 0.9.1 on numlock mask is set automatically. The numlockMask
-- setting should be removed from configs.
--
-- You can safely remove this even on earlier xmonad versions unless you
-- need to set it to something other than the default mod2Mask, (e.g. OSX).
--
-- The mask for the numlock key. Numlock status is "masked" from the
-- current modifier status, so the keybindings will work with numlock on or
-- off. You may need to change this on some systems.
--
-- You can find the numlock modifier by running "xmodmap" and looking for a
-- modifier with Num_Lock bound to it:
--
-- > $ xmodmap | grep Num
-- > mod2        Num_Lock (0x4d)
--
-- Set numlockMask = 0 if you don't have a numlock key, or want to treat
-- numlock status separately.
--
-- myNumlockMask   = mod2Mask -- deprecated in xmonad-0.9.1
------------------------------------------------------------
 
 
-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]
 
-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#000000"
myFocusedBorderColor = "#555577"
 
------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
 
    -- launch a terminal
    [ ((modm, xK_Return), spawn $ XMonad.terminal conf)
 
    -- launch dmenu
    , ((modm,  xK_d), spawn "exe=`dmenu_path | dmenu_run -b ` && eval \"exec $exe\"")
 
    -- launch gmrun
    , ((modm .|. shiftMask, xK_p), spawn "gmrun")

    -- switch between open applications/windows
    , ((modm, xK_Tab     ), gotoMenuConfig dmConf)
    , ((modm .|. shiftMask, xK_Tab     ), bringMenu)
  
    -- close focused window
    , ((modm, xK_q), kill)
 
     -- Rotate through the available layout algorithms
    , ((modm, xK_space ), sendMessage NextLayout)
 
    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)
 
    -- Resize viewed windows to the correct size
    , ((modm, xK_n), refresh)
 
    -- Move focus to the next window
    , ((modm, xK_Right), windows W.focusDown)
 
    -- Move focus to the previous window
    , ((modm, xK_Left), windows W.focusUp)

    -- Move focus to the next window
    , ((modm, xK_j), windows W.focusDown)
 
    -- Move focus to the previous window
    , ((modm, xK_k), windows W.focusUp)
 
    -- Move focus to the master window
    , ((modm, xK_m), windows W.focusMaster)
 
    -- Swap the focused window and the master window
    , ((modm .|. shiftMask, xK_Return), windows W.swapMaster)
 
    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_Right), windows W.swapDown)
 
    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_Left), windows W.swapUp)
 
    -- Shrink the master area
    , ((modm,  xK_h), sendMessage Shrink)
 
    -- Expand the master area
    , ((modm,  xK_l), sendMessage Expand)
 
    -- Push window back into tiling
    , ((modm,  xK_t), withFocused $ windows . W.sink)
 
    -- Increment the number of windows in the master area
    , ((modm, xK_comma ), sendMessage (IncMasterN 1))
 
    -- Deincrement the number of windows in the master area
    , ((modm, xK_period), sendMessage (IncMasterN (-1)))
 
    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    , ((modm, xK_b), sendMessage ToggleStruts)
 
    -- Quit xmonad
    , ((modm .|. shiftMask, xK_Escape), io (exitWith ExitSuccess))
 
    -- Restart xmonad
    , ((modm, xK_Escape), spawn "xmonad --recompile; xmonad --restart")
    , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]                   
    ++
 
    --
    -- mod-[1..9], Switch to workspace N
    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++
 
    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
    ++
    
    --
    -- additional keys
    --
    [ ((0, xF86XK_MonBrightnessUp), spawn "xbacklight -inc 10")
    , ((0, xF86XK_MonBrightnessDown), spawn "xbacklight -dec 10")
    , ((0, xF86XK_AudioRaiseVolume), spawn "amixer set Master 1%+ unmute")
    , ((0, xF86XK_AudioLowerVolume), spawn "amixer set Master 1%- unmute")
    , ((0, xF86XK_AudioMute), spawn "amixer -q set Master toggle && amixer -q set Headphone toggle")
    ]
   where dmConf = def { menuCommand = "dmenu"
                     , menuArgs = ["-b"]
                     }

 
------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $
 
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))
 
    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))
 
    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))
 
    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]
 
------------------------------------------------------------------------
-- Layouts:
 
-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- * NOTE: XMonad.Hooks.EwmhDesktops users must remove the obsolete
-- ewmhDesktopsLayout modifier from layoutHook. It no longer exists.
-- Instead use the 'ewmh' function from that module to modify your
-- defaultConfig as a whole. (See also logHook, handleEventHook, and
-- startupHook ewmh notes.)
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
-- myLayout = tiled ||| Mirror tiled ||| Full ||| (Tall 1 (3/100) (1/2) *//* Full)  ||| (Tall 1 (3/100) (1/2) ***||** Full)
myLayout = tiled ||| Mirror tiled ||| Full
  where
    -- default tiling algorithm partitions the screen into two panes
    tiled   = Tall nmaster delta ratio
 
    -- The default number of windows in the master pane
    nmaster = 1
 
    -- Default proportion of screen occupied by master pane
    ratio   = 1/2
 
    -- Percent of screen to increment by when resizing panes
    delta   = 3/100
 
------------------------------------------------------------------------
-- Window rules:
 
-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
-- myManageHook = composeAll
--     [ className =? "MPlayer"        --> doFloat
--     , className =? "Gimp"           --> doFloat
--     , resource  =? "desktop_window" --> doIgnore
--     , resource  =? "kdesktop"       --> doIgnore ]
myManageHook = manageDocks <+> (isFullscreen --> doFullFloat) <+> manageHook defaultConfig 

------------------------------------------------------------------------
-- Event handling
 
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
-- * NOTE: EwmhDesktops users should use the 'ewmh' function from
-- XMonad.Hooks.EwmhDesktops to modify their defaultConfig as a whole.
-- It will add EWMH event handling to your custom event hooks by
-- combining them with ewmhDesktopsEventHook.
--
myEventHook = mempty
 
------------------------------------------------------------------------
-- Status bars and logging
 
-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
--
-- * NOTE: EwmhDesktops users should use the 'ewmh' function from
-- XMonad.Hooks.EwmhDesktops to modify their defaultConfig as a whole.
-- It will add EWMH logHook actions to your custom log hook by
-- combining it with ewmhDesktopsLogHook.
--
myLogHook xmproc = dynamicLogWithPP $ myxmobarPP xmproc

-- | Customize the formatting of status information.
myxmobarPP :: Handle -> PP
myxmobarPP xmproc = def { ppCurrent = xmobarColor "black" "#3c6e8c" . pad -- . wrap "[" "]"
                        -- ^ how to print the tag of the currently focused
                        -- workspace
                        , ppVisible = wrap "(" ")" . pad
                        -- ^ how to print tags of visible but not focused
                        -- workspaces (xinerama only)
                        , ppHidden =  xmobarColor "gray" "" . pad
                        -- ^ how to print tags of hidden workspaces which
                        -- contain windows
                        , ppHiddenNoWindows = const ""
                        -- ^ how to print tags of empty hidden workspaces
                        , ppUrgent  = xmobarColor "red" "yellow"
                        -- ^ format to be applied to tags of urgent workspaces.
                        , ppSep = "| "
                        -- ^ separator to use between different log sections
                        -- (window name, layout, workspaces)
                        , ppWsSep = ""
                        -- ^ separator to use between workspace tags
                        , ppTitle = xmobarColor "green" "" . shorten 40
                        -- ^ window title format
                        , ppTitleSanitize   = xmobarStrip . dzenEscape
                        -- ^  escape / sanitizes input to 'ppTitle'
                        , ppLayout = const "" -- id
                        -- ^ layout name format
                        , ppOrder = id -- reverse
                        -- ^ how to order the different log sections. By
                        --   default, this function receives a list with three
                        --   formatted strings, representing the workspaces,
                        --   the layout, and the current window title,
                        --   respectively. If you have specified any extra
                        --   loggers in 'ppExtras', their output will also be
                        --   appended to the list.  To get them in the reverse
                        --   order, you can just use @ppOrder = reverse@.  If
                        --   you don't want to display the current layout, you
                        --   could use something like @ppOrder = \\(ws:_:t:_) ->
                        --   [ws,t]@, and so on.
                        , ppSort = getSortByIndex
                        -- ^ how to sort the workspaces.  See
                        -- "XMonad.Util.WorkspaceCompare" for some useful
                        -- sorts.
                        , ppExtras = [ {- myBattery, myDate, i3s, lver, fort, avgl -} ]
                        -- ^ loggers for generating extra information such as
                        -- time and date, system load, battery status, and so
                        -- on.  See "XMonad.Util.Loggers" for examples, or create
                        -- your own!
                        , ppOutput = hPutStrLn xmproc
                        -- ^ applied to the entire formatted string in order to
                        -- output it.  Can be used to specify an alternative
                        -- output method (e.g. write to a pipe instead of
                        -- stdout), and\/or to perform some last-minute
                        -- formatting.
             }
  where
    myBattery = logCmd "/usr/bin/acpi" -- battery
    myDate = date "%a %b %d %Y %H:%M" -- date "%c"
    i3s = logCmd "i3status"
    lver = logCmd "uname -s -r"
    fort = logCmd "fortune -n 40 -s"
    avgl = loadAvg
          
------------------------------------------------------------------------
-- startup hook
 
-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
--
-- * NOTE: EwmhDesktops users should use the 'ewmh' function from
-- XMonad.Hooks.EwmhDesktops to modify their defaultConfig as a whole.
-- It will add initialization of EWMH support to your custom startup
-- hook by combining it with ewmhDesktopsStartup.
--
myStartupHook = return ()
 
------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.
 
-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
  xmproc <- spawnPipe "xmobar"
  xmonad $ docks $ defaults xmproc
 
-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults xmproc = defaultConfig {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        -- numlockMask deprecated in 0.9.1
        -- numlockMask        = myNumlockMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,
 
      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,
 
      -- hooks, layouts
        layoutHook         = avoidStruts $ myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook xmproc,
        startupHook        = myStartupHook
    }

help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Enter        Launch terminal",
    "mod-d            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-q            Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Right      Move focus to the next window",
    "mod-Left       Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Shift-Return       Swap the focused window and the master window",
    "mod-Shift-Right  Swap the focused window with the next window",
    "mod-Shift-Left   Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-Esc  Quit xmonad",
    "mod-Esc        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging",
    "",
    "-- Status bar",
    "mod-b Toggle ON/OFF the status bar"]
    

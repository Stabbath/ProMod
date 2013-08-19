#if defined  _pause_included_
        #endinput
#endif
#define _pause_included_

/**
 * Returns if the game is currently paused from this pause plugin.
 * This can't tell you if it is paused from another plugin on manual pause
 *
 * @return	Current pause state
 */
native bool:IsInPause();

/**
 * Called when a pause starts
 * If delayed pauses are on this will be called when the delay ends and the
 * pause actually begins
 */
forward OnPause();

/**
 * Called when the pause ends and the round goes live
 */
forward OnUnpause();

public SharedPlugin:__pl_pause =
{
	name = "pause",
	file = "pause.smx",
#if defined REQUIRE_PLUGIN
        required = 1,
#else
        required = 0,
#endif
};

public __pl_pause_SetNTVOptional()
{
	MarkNativeAsOptional("IsInPause");
}

// vim: ft=sourcepawn et sw=8

Msg("Initiating Onslaught\n");

DirectorOptions <-
{
	// This turns off tanks and witches.
	ProhibitBosses = true

	PreferredMobDirection = SPAWN_IN_FRONT_OF_SURVIVORS
	MobSpawnMinTime = 3
	MobSpawnMaxTime = 3
	MobMaxPending = 24
	MobMinSize = 24
	MobMaxSize = 24
	SustainPeakMinTime = 3
	SustainPeakMaxTime = 3
	IntensityRelaxThreshold = 0.90
	RelaxMinInterval = 4
	RelaxMaxInterval = 4
	RelaxMaxFlowTravel = 5000
}

Director.ResetMobTimer()
Director.PlayMegaMobWarningSounds()

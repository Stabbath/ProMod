Msg("Initiating Onslaught\n");

DirectorOptions <-
{
	// This turns off tanks and witches.
	ProhibitBosses = true

	PreferredMobDirection = SPAWN_IN_FRONT_OF_SURVIVORS
	MobSpawnMinTime = 5
	MobSpawnMaxTime = 5
	MobMaxPending = 5
	MobMinSize = 5
	MobMaxSize = 5
	SustainPeakMinTime = 3
	SustainPeakMaxTime = 3
	IntensityRelaxThreshold = 0.90
	RelaxMinInterval = 8
	RelaxMaxInterval = 8
	RelaxMaxFlowTravel = 5000
}

Director.ResetMobTimer()
Director.PlayMegaMobWarningSounds()
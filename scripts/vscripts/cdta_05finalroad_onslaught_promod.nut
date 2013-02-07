// Used to fix Detour Ahead's Gauntlet Finale.
// Values were decided based on values in cdta_05finalroadversus.nut + 
// tweaks to make it more balanced for competition.
function StartGauntlet()
{
	DirectorOptions <-
	{
		ProhibitBosses = true
		PreferredMobDirection = SPAWN_IN_FRONT_OF_SURVIVORS
		MobMaxPending = 30
		MobMinSize = 30
		MobMaxSize = 30
		SustainPeakMinTime = 1
		SustainPeakMaxTime = 3

		PanicForever = true
		PausePanicWhenRelaxing = false

		IntensityRelaxThreshold = 0.90
		RelaxMinInterval = 3
		RelaxMaxInterval = 3
		RelaxMaxFlowTravel = 200

		LockTempo = 0
		SpecialRespawnInterval = 20
		PreTankMobMax = 30
		ZombieSpawnRange = 3000
		ZombieSpawnInFog = true

		MobSpawnSize = 30
		CommonLimit = 30

		//GauntletMovementThreshold = 500.0
		//GauntletMovementTimerLength = 5.0
		//GauntletMovementBonus = 2.0
		//GauntletMovementBonusMax = 30.0

		// length of bridge to test progress against.
		BridgeSpan = 10000

		MobSpawnMinTime = 3
		MobSpawnMaxTime = 3

		MobSpawnSizeMin = 30
		MobSpawnSizeMax = 30
	}

	Director.ResetMobTimer();
}

StartGauntlet();

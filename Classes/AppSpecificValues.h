#define kAchievementBackToBack @"com.appuous.Shuzzle.back_to_back"
#define kAchievementConsecutiveCombos @"com.appuous.Shuzzle.consecutive_combos"
#define kAchievementDoubleCombos @"com.appuous.Shuzzle.double_combos"
#define kAchievementTiltExpert @"com.appuous.Shuzzle.tilt_expert"
#define kAchievementOneLife @"com.appuous.Shuzzle.one_life"
#define kAchievementNoPowerups @"com.appuous.Shuzzle.no_powerups"
#define kAchievementLowPts @"com.appuous.Shuzzle.low_pts"
#define kAchievementMedPts @"com.appuous.Shuzzle.med_pts"
#define kAchievementHighPts @"com.appuous.Shuzzle.high_pts"
#define kAchievementEliminator @"com.appuous.Shuzzle.eliminator"

#define kTitleBackToBack @"Back-to-Back"
#define kTitleConsecutiveCombos @"Combo Master"
#define kTitleDoubleCombos @"Double Combos"
#define kTitleTiltExpert @"Tilt Expert"
#define kTitleOneLife @"Comeback Hero"
#define kTitleNoPowerups @"Powered Down"
#define kTitleLowPts @"500 Points"
#define kTitleMedPts @"2500 Points"
#define kTitleHighPts @"5000 Points"
#define kTitleEliminator @"The Eliminator"

#define kRequirementBackToBack			20		// 20
#define kRequirementConsecutiveCombos	10		// 10
#define kRequirementDoubleCombos		5		// 5
#define kRequirementTiltExpert			1000	// 1000
#define kRequirementOneLife				1000	// 1000
#define kRequirementNoPowerups			1000	// 1000
#define kRequirementLowPts				500		// 500
#define kRequirementMedPts				2500	// 2500
#define kRequirementHighPts				5000	// 5000

// back_to_back			com.appuous.Shuzzle.back_to_back		Back-to-Back		Played 20 back-to-back games without breaking.
// consecutive_combos	com.appuous.Shuzzle.consecutive_combos	Combo Master		Matched 10 consecutive color+shape combos.
// double_combos		com.appuous.Shuzzle.double_combos		Double Combos		Matched 5 color+shape combos while using the Double Points power-up.
// tilt_expert			com.appuous.Shuzzle.tilt_expert			Tilt Expert			Scored 1000 or more points in extreme tilt mode.
// one_life				com.appuous.Shuzzle.one_life			Comeback Hero		Scored 1000 or more points with only one life left.
// no_powerups			com.appuous.Shuzzle.no_powerups			Powered Down		Scored 1000 or more points using no power-ups.
// low_pts				com.appuous.Shuzzle.low_pts				500 Points			Scored 500 points.
// med_pts				com.appuous.Shuzzle.med_pts				2500 Points			Scored 2500 points.
// high_pts				com.appuous.Shuzzle.high_pts			5000 Points			Scored 5000 points.
// eliminator			com.appuous.Shuzzle.eliminator			The Eliminator		Only used the Radiation power-up.

typedef enum {
	FGAchievementBackToBack,
	FGAchievementConsecutiveCombos,
	FGAchievementDoubleCombos,
	FGAchievementTiltExpert,
	FGAchievementOneLife,
	FGAchievementNoPowerups,
	FGAchievementLowPts,
	FGAchievementMedPts,
	FGAchievementHighPts,
	FGAchievementEliminator
} FGAchievement;

typedef enum {
	FGPowerupDoubler,
	FGPowerupSlowdown,
	FGPowerupRadiation,
	FGPowerupUniformity,
	FGPowerupExtraLife,
    FGPowerupAutowin,
	FGPowerupExtraTime,
	FGPowerupFreeze,
	FGPowerupNone
} FGPowerup;

typedef enum {
	FGControlSchemeTouchMode,
	FGControlSchemeTiltMode	
} FGControlScheme;

typedef enum {
	FGGameStateInit,
	FGGameStateRunning,
	FGGameStateOver,
	FGGameStatePaused
} FGGameState;

typedef enum {
	FGGameLevelEasy,
	FGGameLevelMedium,
	FGGameLevelHard,
	FGGameLevelExtreme,
	FGGameLevelBlitz
} FGGameLevel;

typedef enum {
	FGPowerupSlotInactive,
	FGPowerupSlotActive,
	FGPowerupSlotInUse
} FGPowerupSlot;

typedef enum {
	FGPowerupUsed,
	FGPowerupUnused
} FGPowerupUse;

typedef enum {
	FGStyledPopupStateGameOver,
	FGStyledPopupStatePause	
} FGStyledPopupState;

#define GAME_CIRCLES				6
#define GAME_TIMERSTEPS				25
#define GAME_POWERUPS				6
#define GAME_POWERUP_SLOTS			3
#define GAME_COLOR					0
#define GAME_SHAPE					1
#define GAME_MAXCOLORS				4
#define GAME_MAXSHAPES				6
#define GAME_MATCHES				2
#define GAME_SLOWDOWN				4
#define GAME_BLITZ_SECONDS			60
#define GAME_BLITZ_EXTRASECONDS		10
#define GAME_BLITZ_PENALTY			10

#define SCORE_COLOR_MATCH			10
#define SCORE_SHAPE_MATCH			1
#define BLITZ_COLOR_MATCH			20
#define BLITZ_SHAPE_MATCH			10

#define BLUE_COLOR					2

#define GOLDEN_COLOR				4
#define GOLDEN_CIRCLE_PROBABILITY	200
#define GOLDEN_CENTER_PROBABILITY	5
#define GOLDEN_POINTS				100

#define BLOCK_DELAY					0.55

#define RADIUS						107.0
#define PI							3.141592653589793

#define ANIM_SHORT					0.3
#define ANIM_NORMAL					0.4
#define ANIM_LONG					1.2

#define PAUSE_BEFORE_COUNTDOWN		0.5

hostname        					= "{{getv "/exile/config/hostname"}}";
password         					= "{{getv "/exile/config/password"}}";
passwordAdmin      					= "{{getv "/exile/config/password/admin"}}";
serverCommandPassword					= "{{getv "/exile/config/password/command"}}";
logFile            					= "server.log";
verifySignatures   					= 1; // Do NOT use verifySignatures=2! It costs too many FPS
BattlEye            					= 1;
requiredBuild 						= 141764; // 1.70 stable
allowedLoadFileExtensions[] 				= {:};
allowedPreprocessFileExtensions[] 			= {"sqf"};
allowedHTMLLoadExtensions[] 				= {"html"};
motdInterval 						= 5;
maxPlayers 						= {{getv "/exile/config/maxplayers"}};
voteMissionPlayers 					= 200;
voteThreshold 						= 200;
allowedVoteCmds[] 					= {};
allowedVotedAdminCmds[]					= {};
disableVoN						= {{getv "/exile/config/von"}};
vonCodecQuality 					= 30;
persistent						= 1;
kickDuplicate 						= 1;
equalModRequired 					= 0;
kickClientsOnSlowNetwork            = 0;
timeStampFormat 					= "short";
onUserConnected 					= "";
onUserDisconnected 					= "";
doubleIdDetected 					= "";
onUnsignedData 						= "kick (_this select 0)";
onHackedData 						= "kick (_this select 0)";
onDifferentData 					= "kick (_this select 0)";
motd[] 							= {{getv "/exile/config/motd"}}; 
// {"Welcome to Arma 3 Exile Mod!", "www.exilemod.com", "Enjoy your stay!" };

class Missions
{
	class Exile
	{
		template = {{getv "/exile/config/mission"}};  // Exile.Namalsk, Exile.Altis, Exile.Tanoa

		// do NOT use custom difficulties!
		// Use either ExileRegular or ExileHardcore
		// or you will break Exile!
		difficulty = "{{getv "/exile/config/difficulty"}}";
	};
};

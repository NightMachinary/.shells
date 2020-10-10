alias mac-mail-log="sudo log stream --predicate  '(process == \"smtpd\") || (process == \"smtp\")' --info" #this command starts filtering, so after that you get log messages when you start accessing smtp.

alias lock='"/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession" -suspend ; pmset displaysleepnow' # Command+Ctrl+q locks natively; Use lock.as to press them ;)) (Needs assistive access)

function finder-hideicons() {
    defaults write com.apple.finder CreateDesktop false
    killall Finder
}
#### nightshift
# @darwinonly https://github.com/leberwurstsaft/nshift/releases
aliasfn nightshift-on nshift 100
aliasfn nightshift-off nshift off
###
# ### Doesn't work. From https://gist.github.com/thomasfinch/14bd3181799734c872d2ad3b207cc01c
# CORE_BRIGHTNESS="/var/root/Library/Preferences/com.apple.CoreBrightness.plist"
# CBUser="CBUser-$(dscl . -read ~ GeneratedUID | sed 's/GeneratedUID: //')"
# ## read:
# # sudo defaults read $CORE_BRIGHTNESS "CBUser-$(dscl . -read ~ GeneratedUID | sed 's/GeneratedUID: //')"
# NIGHTSHIFT_ALWAYS='{
#     CBBlueLightReductionCCTTargetRaw = 2700;
#     CBBlueReductionStatus =     {
#         AutoBlueReductionEnabled = 1;
#         BlueLightReductionAlgoOverride = 4;
#         BlueLightReductionAlgoOverrideTimestamp = "1399-07-18 17:38:24 +0000";
#         BlueLightReductionDisableScheduleAlertCounter = 3;
#         BlueLightReductionSchedule =         {
#             DayStartHour = 7;
#             DayStartMinute = 0;
#             NightStartHour = 7;
#             NightStartMinute = 1;
#         };
#         BlueReductionAvailable = 1;
#         BlueReductionEnabled = 1;
#         BlueReductionMode = 2;
#         BlueReductionSunScheduleAllowed = 1;
#         Version = 1;
#     };
# }'
# ##
# function nightshift-always-darwin() {
#     sudo defaults write $CORE_BRIGHTNESS "$CBUser" "$NIGHTSHIFT_ALWAYS"
# }
# ###
####

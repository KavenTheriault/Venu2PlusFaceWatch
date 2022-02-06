import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;
import Toybox.Weather;

class CustomWatchView extends WatchUi.WatchFace {

    // Fonts
    private var fontSmall;
    private var fontMedium;
    private var fontLarge;

    // Images
    private var background;

    // Contants
    private var centerX, centerY, screenH, screenW;

    // Icons
    const ICON_HEART = "A";
    const ICON_BLUETOOTH = "B";
    const ICON_NOTIFICATION = "C";
	const ICON_ALARM = "D";
	const ICON_MOON = "E";

    const ICON_BATTERY_100 = "F";
    const ICON_BATTERY_75 = "G";
    const ICON_BATTERY_50 = "H";
	const ICON_BATTERY_25 = "I";
	const ICON_BATTERY_0 = "J";

    const ICON_WEATHER_FREEZING_RAIN = "!";
    const ICON_WEATHER_LIGHT_SNOW = "@";
    const ICON_WEATHER_HEAVY_SNOW = "#";
    const ICON_WEATHER_SNOW = "$";
    const ICON_WEATHER_MOSTLY_CLOUDY = "?";
    const ICON_WEATHER_CLEAR = "&";
    const ICON_WEATHER_CLEAR_NIGHT = "*";
    const ICON_WEATHER_MOSTLY_CLEAR = "(";
    const ICON_WEATHER_MOSTLY_CLEAR_NIGHT = ")";
    const ICON_WEATHER_PARTLY_CLOUDY = "\\";
    const ICON_WEATHER_THUNDERSTORMS = "/";
    const ICON_WEATHER_WINDY = "[";
    const ICON_WEATHER_RAIN = "]";
    const ICON_WEATHER_LIGHT_RAIN = "=";

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        // Screen
        screenH = dc.getHeight();
    	screenW = dc.getWidth();
    	centerX = screenW / 2;
    	centerY = screenH / 2;

        // Fonts
        fontSmall = WatchUi.loadResource(Rez.Fonts.CustomSmall);
        fontMedium = WatchUi.loadResource(Rez.Fonts.CustomMedium);
        fontLarge = WatchUi.loadResource(Rez.Fonts.CustomLarge);

        // Images
        background = WatchUi.loadResource(Rez.Drawables.Background);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Clear
        dc.clear();

        // Background
        dc.drawBitmap(0, 0, background);

        // Text color
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // Time
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour.format("%02d"), clockTime.min.format("%02d")]);
        dc.drawText(centerX, 115, fontLarge, timeString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Date
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dateString = Lang.format("$1$ $2$ $3$", [today.day_of_week.toLower(), today.day, today.month.toLower()]);
        dc.drawText(centerX, 185, fontMedium, dateString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        var dataHeight = 266;
        var sideDataDistance = 130;

        // Weather
        var weather = Weather.getCurrentConditions();
        var weatherString = Lang.format("$1$ $2$", [getWeatherIcon(weather.condition, clockTime), weather.temperature.format("%2d")]);
        dc.drawText(centerX - sideDataDistance, dataHeight, fontMedium, weatherString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // HR
        var hr = Activity.getActivityInfo().currentHeartRate;
        if (hr == null) {
            hr = "--";
        }
        var hrString = Lang.format("$1$ $2$", [ICON_HEART, hr]);
        dc.drawText(centerX, dataHeight, fontMedium, hrString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Battery
        var sysStats = System.getSystemStats();
        var batteryIcon;
        if (sysStats.battery > 90) {
            batteryIcon = ICON_BATTERY_100;
        } else if (sysStats.battery > 60) {
            batteryIcon = ICON_BATTERY_75;
        } else if (sysStats.battery > 30) {
            batteryIcon = ICON_BATTERY_50;
        } else if (sysStats.battery > 5) {
            batteryIcon = ICON_BATTERY_25;
        } else {
            batteryIcon = ICON_BATTERY_0;
        }
        var batteryString = Lang.format("$1$ $2$", [batteryIcon, sysStats.battery.format("%2d")]);
        dc.drawText(centerX + sideDataDistance, dataHeight, fontMedium, batteryString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Icons
        var iconsString = "";
        var settings = System.getDeviceSettings();
	    if (settings.phoneConnected) {
            iconsString += ICON_BLUETOOTH + " ";
	    }
	    if (settings.notificationCount > 0) {
            iconsString += ICON_NOTIFICATION + " ";
	    }
        if (settings.alarmCount > 0) {
            iconsString += ICON_ALARM + " ";
	    }
        if (settings.doNotDisturb) {
            iconsString += ICON_MOON + " ";
        }
        iconsString = iconsString.substring(0, iconsString.length() - 1);
        dc.drawText(centerX, screenH - 30, fontSmall, iconsString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

    function getWeatherIcon(condition, clockTime) {
		var isNight = clockTime.hour >= 20 or clockTime.hour < 6;
		var icon;
		switch(condition){
			case Toybox.Weather.CONDITION_CLEAR:{
                if (isNight) {
                    icon = ICON_WEATHER_CLEAR_NIGHT;
                } else {
                    icon = ICON_WEATHER_CLEAR;
                }
				break;
			}
			case Toybox.Weather.CONDITION_PARTLY_CLOUDY:{
				icon = ICON_WEATHER_PARTLY_CLOUDY;
				break;
			}
			case Toybox.Weather.CONDITION_MOSTLY_CLOUDY:{
				icon = ICON_WEATHER_MOSTLY_CLOUDY;
				break;
			}
			case Toybox.Weather.CONDITION_RAIN:{
				icon = ICON_WEATHER_RAIN;
				break;
			}
			case Toybox.Weather.CONDITION_SNOW:{
				icon = ICON_WEATHER_SNOW;
				break;
			}
			case Toybox.Weather.CONDITION_WINDY:{
				icon = ICON_WEATHER_WINDY;
				break;
			}
			case Toybox.Weather.CONDITION_THUNDERSTORMS:{
				icon = ICON_WEATHER_THUNDERSTORMS;
				break;
			}
            case Toybox.Weather.CONDITION_SCATTERED_THUNDERSTORMS:{
				icon = ICON_WEATHER_THUNDERSTORMS;
				break;
			}
			case Toybox.Weather.CONDITION_LIGHT_RAIN:{
				icon = ICON_WEATHER_LIGHT_RAIN;
				break;
			}
			case Toybox.Weather.CONDITION_HEAVY_RAIN:{
				icon = ICON_WEATHER_RAIN;
				break;
			}
			case Toybox.Weather.CONDITION_LIGHT_SNOW:{
				icon = ICON_WEATHER_LIGHT_SNOW;
				break;
			}
			case Toybox.Weather.CONDITION_HEAVY_SNOW:{
				icon = ICON_WEATHER_HEAVY_SNOW;
				break;
			}
			case Toybox.Weather.CONDITION_LIGHT_RAIN_SNOW:{
				icon = ICON_WEATHER_LIGHT_RAIN;
				break;
			}
			case Toybox.Weather.CONDITION_HEAVY_RAIN_SNOW:{
				icon = ICON_WEATHER_RAIN;
				break;
			}
			case Toybox.Weather.CONDITION_CLOUDY:{
				icon = ICON_WEATHER_MOSTLY_CLOUDY;
				break;
			}
			case Toybox.Weather.CONDITION_RAIN_SNOW:{
				icon = ICON_WEATHER_RAIN;
				break;
			}
			case Toybox.Weather.CONDITION_PARTLY_CLEAR:{
				icon = ICON_WEATHER_PARTLY_CLOUDY ;
				break;
			}
			case Toybox.Weather.CONDITION_MOSTLY_CLEAR:{
                if (isNight) {
                    icon = ICON_WEATHER_MOSTLY_CLEAR_NIGHT;
                } else {
                    icon = ICON_WEATHER_MOSTLY_CLEAR;
                }
				break;
			}
			case Toybox.Weather.CONDITION_LIGHT_SHOWERS:{
				icon = ICON_WEATHER_MOSTLY_CLEAR;
				break;
			}
			case Toybox.Weather.CONDITION_SHOWERS:{
				icon = ICON_WEATHER_RAIN;
				break;
			}
			case Toybox.Weather.CONDITION_HEAVY_SHOWERS:{
				icon = ICON_WEATHER_RAIN;
				break;
			}
			case Toybox.Weather.CONDITION_FREEZING_RAIN:{
				icon = ICON_WEATHER_FREEZING_RAIN;
				break;
			}
			default:{
				icon = ICON_WEATHER_PARTLY_CLOUDY;
				break;
			}
		}
		return icon;
	}

}

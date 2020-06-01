
var healthkitManager = require("HealthkitManager");

Ti.API.info("@@@@@@@@@"+Ti.Platform.getUsername());

Ti.API.info('@@@@supported ' + healthkitManager.isSupported());

healthkitManager.authorize(function(e){
	Ti.API.info("app callbackkkkk authorize"+e);
});

var HealthKit = require("com.moiz.healthkit");
var readTypes = {
	HKCategoryType : [],
	HKCharacteristicType : [],
	HKCorrelationType : [],
	HKQuantityType : ["HKQuantityTypeIdentifierStepCount", "HKQuantityTypeIdentifierActiveEnergyBurned"],
	HKWorkoutType : ["HKWorkoutType"]
};
var writeTypes = {
	
};
function enableBackgroundQuery() {
	var _writeTypes = [
	//HealthKit.OBJECT_TYPE_STEP_COUNT
	];
	var _readTypes = {
		HKCategoryType : [],
		HKCharacteristicType : [],
		HKCorrelationType : [],
		HKQuantityType : ["HKQuantityTypeIdentifierStepCount", "HKQuantityTypeIdentifierActiveEnergyBurned"],
		HKWorkoutType : ["HKWorkoutType"]
	};
	HealthKit.enableBackgroundDelivery(_writeTypes, _readTypes, enableBackgroundDeliveryStepsCallback);
}

getWorkoutCallback = function(res) {

	if (res.success == 1) {
		//Ti.API.info('>>>>>>>.getWorkoutCallback' + JSON.stringify(res));
	} else {
		//Ti.API.info('>>>>>>>>error getWorkoutCallback');
	}

};

updateObserveStepsCallback = function(res) {
	Ti.API.info('updateObserveStepsCallbackupdateObserveStepsCallbackupdateObserveStepsCallback');
	
		
		var totSteps = 0;
		for (var i = 0; i < res.arrValues.length; i++) {
			totSteps = totSteps + res.arrValues[i].steps;
		}
		

};
var win = Ti.UI.createWindow({
		title : "Healthkit",
		backgroundColor : '#fff'
	});

var btnGetSetps = Ti.UI.createButton({
	title:"Get Steps",
	width:Ti.UI.SIZE,
	height:"100",
	top:100,
});
win.add(btnGetSetps);
btnGetSetps.addEventListener('click', function(e){
	var date = new Date();
	date.setDate(5);
	var fromDt = new Date();
	fromDt.setDate(7); 
	healthkitManager.getDailySteps(date,fromDt,function(res){
	
	});
	
});

var btnEnergyBurned = Ti.UI.createButton({
	title:"Energy Burned",
	width:Ti.UI.SIZE,
	height:"100",
	top:200,
});
win.add(btnEnergyBurned);
btnEnergyBurned.addEventListener('click', function(e){
	var date = new Date();
	date.setDate(16);
	var fromDt = new Date();
	fromDt.setDate(18); 
	healthkitManager.getEnergyBurned(date,fromDt,function(res){
	
	});
	
});


var btnGetDistance = Ti.UI.createButton({
	title:"Get Distance",
	width:Ti.UI.SIZE,
	height:"100",
	top:300,
});
win.add(btnGetDistance);
btnGetDistance.addEventListener('click', function(e){
	var date = new Date();
	date.setDate(6);
	healthkitManager.getDistance(date,function(res){
		
		var count = 0;
		for(var i=0; i<res.arrValues.length;i++){
			count = count + res.arrValues[i].count;
		}
		alert(count + "####"+res.totalDistance);
	});
});
win.open();


var DEVICE_IPHONE = "iPhone";
var DEVICE_WATCH = "AppleWatch";


var HealthKit = require("com.moiz.healthkit");

var stepObserverQuery = null;

var writeTypes = {

};
function getFormattedDate(date) {
  var year = date.getFullYear();

  var month = (1 + date.getMonth()).toString();
  month = month.length > 1 ? month : '0' + month;

  var day = date.getDate().toString();
  day = day.length > 1 ? day : '0' + day;
  
  return month + '/' + day + '/' + year;
}
var readTypes = {
	HKCategoryType : [],
	HKCharacteristicType : [],
	HKCorrelationType : [],
	HKQuantityType : ["HKQuantityTypeIdentifierStepCount", "HKQuantityTypeIdentifierActiveEnergyBurned"],
	HKWorkoutType : ["HKWorkoutType"]
};


// Summarize an array with steps to a sum
function getTotalSumFromArray(arr) {
	var sum = 0;

	for (var k in arr) {
		sum += arr[k];
	}

	return sum;
}

// Filter sources from #steps (E.g manually added steps)
function filterSources(sample, _convert_to, _disable_strict) {
	var convert_to = (_convert_to == undefined) ? "count" : _convert_to;
	var device_name = Ti.Platform.getUsername();
	var data = {};

	for (var i = 0; i < sample.length; i++) {
		var _source = sample[i].source;

		if (_source.bundleIdentifier == "com.apple.Health") {
			continue;
		}

		var _source_name = (_source.name === device_name) ? DEVICE_IPHONE : _source.name;

		if (data[_source_name] == undefined) {
			data[_source_name] = 0;
		}

		data[_source_name] += sample[i].quantity.valueForUnit(HealthKit.createUnit(convert_to));
	}

	return data;
}

/* Filter away all data which we dont want, return highest, and best fitted */
function filterBestData(_data) {
	var sortable = new Array();

	for (var k in _data) {
		sortable.push([k, _data[k]]);
	}

	sortable.sort(function(a, b) {
		return b[1] - a[1];
	});

	return {
		source : sortable[0][0],
		count : sortable[0][1]
	};
}

// Actually initializes the popup for the user to allow HK with SR
exports.authorize = function(_callback) {
	HealthKit.requestAuthorization(writeTypes, readTypes, function(e) {
		Ti.API.info("HealthKit.requestAuthorization " + e);
		if (e.success != undefined && e.success == 1) {
			enableBackgroundQuery();
			Ti.API.info('auth successssss');
			startStepObserveQuery(function(res) {
				//Ti.API.info('res' + JSON.stringify(res));
				if (res) {
					Ti.API.info('From startStepObserveQuery callback');
					_callback(true);

					// if (e.completionToken != undefined) {
					// HealthKit.callObserverQueryCompletionHandler(e.completionToken);
					// }
				} else {
					_callback(false);
				}
			});
		} else {
			_callback(false);
		}
	});
};

// Since we cant check for Read-permissions, we have to fake a steps-fetch
exports.isAuthorized = function(_callback) {
	exports.getSteps(new Date(), function(_steps) {
		if (!_steps) {
			_callback(false);
		} else {
			_callback(true);
		}
	});
};

// Does this phone have HK installed?
exports.isSupported = function() {
	return HealthKit.isHealthDataAvailable();
};

// The onUpdate callback will fire immediately after executing the
// observerQuery if there are matching entries in the data store.
// After that, the callback will be called every time a matching
// entry is added or deleted, until the query is finally stopped.
function startStepObserveQuery(_callback) {
	if (isStepObserverQueryRunning()) {
		if ( typeof (_callback) == "function") {
			_callback(true);
		}

		return;
	}
	var dateFrom = new Date();
	var dateTo = new Date();
	
	dateFrom.setHours(0, 0, 0, 0);
	dateTo.setHours(23, 59, 59, 999);
	
	
	
	// For getting total steps taken by users

	Ti.API.info('stepObserverQuery valueee hussain' + stepObserverQuery);

	updateObserveStepsCallback = function(res) {
	
		if(res.success){
		
			_callback(res);
			
		}
		else{
			_callback(false);
		}
		

	};
	
	stepObserverQuery = HealthKit.observeSteps(getFormattedDate(dateFrom) + " "+ "00:00:00",(getFormattedDate(dateTo)) + " "+ "23:59:59", updateObserveStepsCallback);
}

function stopStepObserverQuery() {
	if (!stepObserverQuery) {
		console.log('Steps observer query is not running.');
		return;
	}

	HealthKit.stopQuery(stepObserverQuery);
	stepObserverQuery = null;
}

exports.stopStepObserverQuery = stopStepObserverQuery;

function isStepObserverQueryRunning() {
	return stepObserverQuery !== null;
}

exports.isStepObserverQueryRunning = isStepObserverQueryRunning;

function enableBackgroundQuery() {
	var _writeTypes = [];
	var _readTypes = {
		HKCategoryType : [],
		HKCharacteristicType : [],
		HKCorrelationType : [],
		HKQuantityType : ["HKQuantityTypeIdentifierStepCount", "HKQuantityTypeIdentifierActiveEnergyBurned"],
		HKWorkoutType : ["HKWorkoutType"]
	};
	HealthKit.enableBackgroundDelivery(_writeTypes, _readTypes, function(e) {
		if (e.success) {
			Ti.API.info("hereeee enableBackgroundDelivery success");
			Ti.App.Properties.setBool('BACKGROUND_DELIVERY_ENABLED', true);
		} else {
			Ti.API.info("hereeee enableBackgroundDelivery error");
			Ti.API.info(e);
		}
	});
}

function disableBackgroundQuery() {
	HealthKit.disableBackgroundDelivery({
		type : HealthKit.OBJECT_TYPE_STEP_COUNT,
		onCompletion : function(e) {
			if (e.success) {
				Ti.App.Properties.setBool('BACKGROUND_DELIVERY_ENABLED', false);
			} else {
				console.log(e);
			}
		}
	});
}

// Fetch distance
exports.getDistance = function(date, _callback, completionToken) {
	
	var dateFrom = date;
	var dateTo = new Date(date);
	dateFrom.setHours(0, 0, 0, 0);
	dateTo.setHours(23, 59, 59, 999);

	updateObserveStepsCallback = function(res){
		if (res.success) {
			//Ti.API.info('>>>>>>>.getWorkoutCallback' + JSON.stringify(res));
			_callback(res);
		} else {
			//Ti.API.info('>>>>>>>>error getWorkoutCallback');
			_callback(0);
		}
	};
	
	HealthKit.readDistanceWalkingRunning(getFormattedDate(dateFrom) + " "+ "00:00:00",getFormattedDate(dateTo) + " "+ "23:59:59", updateObserveStepsCallback); // For getting total steps taken by users
	
	
};

// Fetch steps
exports.getSteps = function(date, _callback, completionToken,_toDate) {
	// The user granted the app's request to share.
	// Set date to 00:00:01 - 23:59:59 to cover the whole day
	updateObserveStepsCallback = function(res){
		
		if(res.success){
			
			_callback(res);
		}
		else{
			_callback(0);
		}
		
	};
	var dateFrom = date;
	//Ti.API.info('@@@@@@dateFromdateFromdateFrom'+dateFrom);
	if(_toDate){
		dateTo = _toDate;
	}
	else{
		var dateTo = new Date();
	}
	
	
	dateFrom.setHours(0, 0, 0, 0);
	dateTo.setHours(18, 59, 59, 999);
	

	stepObserverQuery = HealthKit.observeSteps(getFormattedDate(dateFrom) + " "+ "00:00:00",(getFormattedDate(dateTo)) + " "+ "23:59:59", updateObserveStepsCallback);
	

};
exports.getDailySteps = function(date,_toDate, _callback) {
	// The user granted the app's request to share.
	// Set date to 00:00:01 - 23:59:59 to cover the whole day
	updateObserveStepsCallback = function(res){

		if(res.success){
			
			_callback(res);
		}
		else{
			_callback(0);
		}
		
	};
	var dateFrom = date;
	//Ti.API.info('@@@@@@dateFromdateFromdateFrom'+dateFrom);
	if(_toDate){
		dateTo = _toDate;
	}
	else{
		var dateTo = new Date();
	}
	
	
	dateFrom.setHours(0, 0, 0, 0);
	dateTo.setHours(18, 59, 59, 999);
	
//Ti.API.info('from:--->>>!!!!! '+ dateFrom.toLocaleDateString() + "#####"+getFormattedDate(dateFrom));
	//Ti.API.info('to:--->>>!!!!!!! '+ dateTo.toLocaleDateString() + "#####"+getFormattedDate(dateTo));
	stepObserverQuery = HealthKit.observeStatisticsSteps(getFormattedDate(dateFrom) + " "+ "00:00:00",(getFormattedDate(dateTo)) + " "+ "23:59:59", updateObserveStepsCallback);
	
};
exports.getEnergyBurned  = function(date,_toDate, _callback){
			Ti.API.info('energyburned');

	updateObserveStepsCallback = function(res){
	
		if(res.success){
			
			_callback(res);
		}
		else{
			_callback(0);
		}
		
	};
	var dateFrom = date;
	Ti.API.info('@@@@@@dateFromdateFromdateFrom'+dateFrom);
	if(_toDate){
		dateTo = _toDate;
	}
	else{
		var dateTo = new Date();
	}
	
	
	dateFrom.setHours(0, 0, 0, 0);
	dateTo.setHours(18, 59, 59, 999);
	
//Ti.API.info('from:--->>>!!!!! '+ dateFrom.toLocaleDateString() + "#####"+getFormattedDate(dateFrom));
//	Ti.API.info('to:--->>>!!!!!!! '+ dateTo.toLocaleDateString() + "#####"+getFormattedDate(dateTo));
	HealthKit.energyBurnedOne(getFormattedDate(dateFrom) + " "+ "00:00:00",(getFormattedDate(dateTo)) + " "+ "23:59:59", updateObserveStepsCallback);
	

};
exports.getRangedData = function(_to_fetch, date_from, date_to, _callback, completionToken) {
	var fetch_type = (_to_fetch == "steps") ? HealthKit.OBJECT_TYPE_STEP_COUNT : HealthKit.OBJECT_TYPE_ACTIVE_ENERGY_BURNED;

	// The user granted the app's request to share.
	// Set date to 00:00:01 - 23:59:59 to cover the whole day
	var anchorDate = new Date(date_from);
	anchorDate.setHours(0, 0, 0, 0);
	// midnight

	// Since we expect the date_to to be included, we have to +1 day to it, so it's not left out
	date_to.setDate(date_to.getDate() + 1);

	HealthKit.executeQuery(HealthKit.createStatisticsCollectionQuery({
		type : fetch_type,
		filter : HealthKit.createFilterForSamples({
			startDate : date_from,
			endDate : date_to
		}),
		options : HealthKit.STATISTICS_OPTION_CUMULATIVE_SUM | HealthKit.STATISTICS_OPTION_SEPARATE_BY_SOURCE,
		anchorDate : anchorDate,
		interval : 3600 * 24, // 24 hours
		onInitialResults : function(e) {
			if (e.errorCode !== undefined) {
				//Utils.showError(e);
			} else {
				var return_data = [];

				for (var i in e.statisticsCollection.statistics) {
					var statistics = e.statisticsCollection.statistics[i];

					var data = {
						date : Lib.dateToString(statistics.startDate)
					};
					var device_name = Ti.Platform.getUsername();

					var count_data = {};

					for (var k in statistics.sources) {
						var _source = statistics.sources[k];

						if (_source.bundleIdentifier == "com.apple.Health") {
							continue;
						}

						var quantity = statistics.getSumQuantity(_source);

						if (!quantity) {
							continue;
						}

						var _source_name = (_source.name === device_name) ? DEVICE_IPHONE : _source.name;

						if (count_data[_source_name] == undefined) {
							count_data[_source_name] = 0;
						}

						var _unit = (_to_fetch == "steps") ? "count" : "kcal";

						count_data[_source_name] += Math.round(quantity.valueForUnit(HealthKit.createUnit(_unit)));
					}

					if (Lib.isEmptyObject(count_data)) {
						continue;
					}

					// Sort by best match (>#steps)
					var sortable = new Array();

					for (var k in count_data) {
						sortable.push([k, count_data[k]]);
					}

					sortable.sort(function(a, b) {
						return b[1] - a[1];
					});

					return_data.push({
						date : data.date,
						source : sortable[0][0],
						count : sortable[0][1]
					});
				}

				if (Lib.isEmptyObject(return_data)) {
					_callback(false);
				} else {
					_callback(return_data);
				}
			}
		}
	}));
};

function filterDevice(_data, _filter_identifier) {
	var return_data = new Array();
	var statistics = e.statisticsCollection.statistics[i];

	var data = {
		date : Lib.dateToString(statistics.startDate)
	};
	var device_name = Ti.Platform.getUsername();

	var count_data = {};

	for (var k in statistics.sources) {
		var _source = statistics.sources[k];

		if (_source.bundleIdentifier.indexOf("com.apple.health") < 0) {
			continue;
		}

		var quantity = statistics.getSumQuantity(_source);

		if (!quantity) {
			continue;
		}

		var count_data = Math.round(quantity.valueForUnit(HealthKit.createUnit('count')));

		if (_source.name === device_name) {
			count_data.device = count_data;
		} else {
			count_data.watch = count_data;
		}
	}

	// Now only return the Device || Watch, depending on which has the highest steps
	var _count;
	var _source;

	// If we get steps from both Device + Apple Watch
	if (count_data.device != undefined && count_data.watch != undefined) {
		if (count_data.device > data.watch) {
			_count = count_data.device;
			_source = DEVICE_IPHONE;
		} else {
			_count = count_data.watch;
			_source = DEVICE_WATCH;
		}
	} else if (count_data.device != undefined) {
		_count = count_data.device;
		_source = DEVICE_IPHONE;
	} else if (count_data.watch != undefined) {
		_count = count_data.watch;
		_source = DEVICE_WATCH;
	}

	var _item = {
		date : data.date,
		source : _source
	};
	_item[_filter_identifier] = _count;

	return_data.push(_item);
}

exports.getEnergy = function(date, _callback, completionToken) {
	var dateFrom = date;
	var dateTo = new Date(date);
	dateFrom.setHours(0, 0, 0, 0);
	dateTo.setHours(23, 59, 59, 999);

	HealthKit.executeQuery(HealthKit.createAnchoredObjectQuery({
		type : HealthKit.OBJECT_TYPE_ACTIVE_ENERGY_BURNED,
		filter : HealthKit.createFilterForSamples({
			startDate : dateFrom,
			endDate : dateTo,
			options : HealthKit.QUERY_OPTION_STRICT_START_DATE
		}),
		onCompletion : function(e) {
			if (e.results == undefined || e.results.length == 0) {
				_callback(0);
				return;
			}

			// Remove manually added steps, "Health" if they are manually added. "health" if automaticle
			var _energy_data = filterSources(e.results, "kcal");
			//, true); // m == meters

			if (_energy_data.length == 0) {
				_callback(0);
			}

			var _best_fitted_data = filterBestData(_energy_data);
			_best_fitted_data.date = Lib.dateToString(dateFrom);

			// Return everything
			_callback(_best_fitted_data);

			if (completionToken !== undefined) {
				HealthKit.callObserverQueryCompletionHandler(completionToken);
			}
		}
	}));
};

/**
 * This function actually checks for new steps upon AppStart + Resume
 */
exports.syncHealthKitData = function() {
	App.HealthKitManager.authorize(function(e) {
		var today_date = new Date();
		var steps_fetched = false;
		var calories_fetched = false;
		var steps_data = new Array();
		var calories_data = new Array();
		var calories_today = 0;
		var steps_today = 0;

		App.HealthKitManager.getSteps(today_date, function(_steps_today) {
			// Found steps today
			if (!_steps_today || _steps_today['count'] <= 0) {
				steps_fetched = true;
				return;
			}

			steps_today = _steps_today['count'];

			// Great, we found steps taken today, compare to cached steps
			var steps_taken_today = App.DatabaseManager.getHKData("steps", today_date);

			if (_steps_today['count'] <= steps_taken_today) {
				steps_fetched = true;
				return;
			}

			// The #steps taken today is more than the cached result
			App.DatabaseManager.setHKDataToday("steps", _steps_today['count']);

			var date_from = new Date();
			var date_to = new Date();

			date_from.setDate(date_from.getDate() - 3);
			date_to.setDate(date_to.getDate() - 1);

			// This means we should fetch steps from more days, and push to the server
			App.HealthKitManager.getRangedData("steps", date_from, date_to, function(_steps_data) {
				steps_fetched = true;

				if (!_steps_data) {
					return;
				}

				steps_data = (_steps_data) ? _steps_data : new Array();
			});
		});

		App.HealthKitManager.getEnergy(new Date(), function(_energy) {
			if (!_energy || _energy['count'] <= 0) {
				calories_fetched = true;
				return;
			}

			calories_today = Math.round(_energy['count']);

			// Great, we found steps taken today, compare to cached steps
			var db_calories_today = App.DatabaseManager.getHKData("calories", today_date);

			if (_energy['count'] <= db_calories_today) {
				calories_fetched = true;
				return;
			}

			// The #steps taken today is more than the cached result
			App.DatabaseManager.setHKDataToday("calories", _energy['count']);

			var date_from = new Date();
			var date_to = new Date();

			date_from.setDate(date_from.getDate() - 3);
			date_to.setDate(date_to.getDate() - 1);

			// This means we should fetch steps from more days, and push to the server
			App.HealthKitManager.getRangedData("calories", date_from, date_to, function(_calories_data) {
				calories_fetched = true;

				if (!_calories_data) {
					return;
				}

				calories_data = (_calories_data) ? _calories_data : new Array();
			});
		});

		var _timer = setInterval(function() {
			if (!calories_fetched || !steps_fetched) {
				return;
			}

			clearInterval(_timer);

			var dashboardWindow = App.scanForWindow("dashboard");
			var Lib = new (require(App.AppController.LIB))();

			// Push data to the dashboard if present
			if (dashboardWindow && typeof (dashboardWindow.setSteps) == "function") {
				var steps_calories = (steps_today > 0 && dashboardWindow) ? Lib.stepsToEnergy(dashboardWindow.cached_user.weight, steps_today) : 0;
				var dashboard_calories = (calories_today > steps_calories) ? calories_today : steps_calories;

				dashboardWindow.setSteps(steps_today);
				dashboardWindow.setEnergyToday(dashboard_calories);
			}

			// No data found, rly?
			if (calories_data.length == 0 && steps_data.length == 0) {
				return;
			}

			var last_hk_api_request = App.DatabaseManager.getLastSentHKRequest();

			if (last_hk_api_request) {
				var date_now = new Date();

				// Only allow requests every 60second
				if ((Math.round((date_now.getTime() - last_hk_api_request) / 1000)) < 60) {
					return;
				}
			}

			var stepsTask = new (require(App.AppController.SPLASHLOGINMODULE.TASK))();
			stepsTask.syncHKData(steps_data, calories_data);
			stepsTask = null;

			dashboardWindow.setCaloriesLastSynced();

			App.DatabaseManager.setLastSentHKRequest();

			// Refresh the dashboard
			if (dashboardWindow && typeof (dashboardWindow.setSteps) == "function") {
				dashboardWindow.refresh();
			}
		}, 100);
	});
};

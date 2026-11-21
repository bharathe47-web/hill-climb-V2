class_name VehicleRegistry
extends RefCounted

const SaveManager = preload("res://scripts/core/SaveManager.gd")

## VehicleRegistry: Central catalog of vehicles, stat profiles, and upgrade configs.
## Serves as a completely decoupled contract for Garage, UI, and Level integration.

const STARTER_IDS: Array[String] = [
	"blue_flame_truck",
	"orc_racer",
	"trophy_truck",
	"dune_buggy"
]

const GARAGE_COLLECTED_IDS: Array[String] = [
	"car_01",
	"car_02",
	"car_04",
	"car_06",
	"car_07",
	"car_08",
	"car_10",
	"car_11",
	"car_14",
	"car_15",
	"car_16",
	"car_17",
	"car_18",
	"car_19",
	"car_24",
	"car_25",
]

const ORDERED_IDS: Array[String] = [
	"blue_flame_truck",
	"orc_racer",
	"trophy_truck",
	"dune_buggy",
	"car_01",
	"car_02",
	"car_04",
	"car_06",
	"car_07",
	"car_08",
	"car_10",
	"car_11",
	"car_14",
	"car_15",
	"car_16",
	"car_17",
	"car_18",
	"car_19",
	"car_24",
	"car_25",
]

## Named setting for global boost multiplier (1.0 = normal original boost power across all vehicles & bikes)
const GLOBAL_BOOST_MULTIPLIER: float = 1.0
const DEFAULT_BASE_BOOST_FORCE: float = 18000.0
const BIGFOOT_BOOST_FORCE: float = 45000.0

## Unified Boost Configuration
const BOOST_POWER_MULTIPLIER: float = 1.0
const BIGFOOT_BOOST_BONUS: float = 1.15

## Real-Life Physics Units & Constants
## A standard car wheel (0.65 m diameter) matches its drawn size (~44.2 px diameter)
const PIXELS_PER_METER: float = 68.0
const REAL_GRAVITY_MPS2: float = 9.8
const GRAVITY_PIXELS: float = REAL_GRAVITY_MPS2 * PIXELS_PER_METER # 666.4 px/s^2

## Base shared realistic suspension presets (data-driven)
## Cars: bodyFrequencyHz 2.0, dampingRatio 0.7, maxTravel 0.25, bumpStop 0.25, reboundLimit 0.25
const SUSPENSION_CONFIG_CAR: Dictionary = {
	"bodyFrequencyHz": 2.0,
	"dampingRatio": 0.7,
	"maxTravel": 0.25,
	"bumpStop": 0.25,
	"reboundLimit": 0.25,
	"body_frequency_hz": 2.0,
	"damping_ratio": 0.7,
	"max_travel": 0.25,
	"bump_stop": 0.25,
	"rebound_limit": 0.25,
}

## Trucks: bodyFrequencyHz 1.6, dampingRatio 0.7, maxTravel 0.35, bumpStop 0.35, reboundLimit 0.35
const SUSPENSION_CONFIG_TRUCK: Dictionary = {
	"bodyFrequencyHz": 1.6,
	"dampingRatio": 0.7,
	"maxTravel": 0.35,
	"bumpStop": 0.35,
	"reboundLimit": 0.35,
	"body_frequency_hz": 1.6,
	"damping_ratio": 0.7,
	"max_travel": 0.35,
	"bump_stop": 0.35,
	"rebound_limit": 0.35,
}

## Bigfoot Heavy Monster Truck: bodyFrequencyHz 1.4, dampingRatio 0.75, maxTravel 0.40
const SUSPENSION_CONFIG_BIGFOOT: Dictionary = {
	"bodyFrequencyHz": 1.4,
	"dampingRatio": 0.75,
	"maxTravel": 0.40,
	"bumpStop": 0.40,
	"reboundLimit": 0.40,
	"body_frequency_hz": 1.4,
	"damping_ratio": 0.75,
	"max_travel": 0.40,
	"bump_stop": 0.40,
	"rebound_limit": 0.40,
}

## Sport bikes: bodyFrequencyHz 2.6, dampingRatio 0.65, maxTravel 0.20
const SUSPENSION_CONFIG_SPORT_BIKE: Dictionary = {
	"bodyFrequencyHz": 2.6,
	"dampingRatio": 0.65,
	"maxTravel": 0.20,
	"bumpStop": 0.20,
	"reboundLimit": 0.20,
	"body_frequency_hz": 2.6,
	"damping_ratio": 0.65,
	"max_travel": 0.20,
	"bump_stop": 0.20,
	"rebound_limit": 0.20,
}

## Cruiser and touring bikes: bodyFrequencyHz 1.8, dampingRatio 0.7, maxTravel 0.25
const SUSPENSION_CONFIG_CRUISER_BIKE: Dictionary = {
	"bodyFrequencyHz": 1.8,
	"dampingRatio": 0.7,
	"maxTravel": 0.25,
	"bumpStop": 0.25,
	"reboundLimit": 0.25,
	"body_frequency_hz": 1.8,
	"damping_ratio": 0.7,
	"max_travel": 0.25,
	"bump_stop": 0.25,
	"rebound_limit": 0.25,
}

## Unified vehicle & bike geometry, wheel fitment, and offset configurations.
## Measures exact wheel arches (cars) and swingarm/fork axles (bikes) in body image pixels.
const VEHICLE_CONFIGS: Dictionary = {
	"blue_flame_truck": {
		"front_weight_ratio": 0.52,
		"rear_weight_ratio": 0.48,

		"base_brake_torque": 18000000.0,
		"base_torque": 32000000.0,
		"air_drag_coeff": 0.02,
		"rolling_resistance": 0.022,
		"center_of_mass": Vector2(0.0, 2.0),
		"wheel_mass": 45.0,
		"driveType": "AWD",
		"drive_type": "AWD",
		"mass": 2500.0,
		"bodyFrequencyHz": 1.6,
		"dampingRatio": 0.7,
		"maxTravel": 0.35,
		"bumpStop": 0.35,
		"reboundLimit": 0.35,
		"body_frequency_hz": 1.6,
		"damping_ratio": 0.7,
		"max_travel": 0.35,
		"bump_stop": 0.35,
		"rebound_limit": 0.35,
		"name": "Blue Flame Truck",
		"bodyImage": "res://assets/vehicles/blue_flame_truck/vehicle_body_truck_side.png",
		"wheelImage": "res://assets/vehicles/blue_flame_truck/wheel_rear.png",
		"bodyScale": 0.18,
		"rearWheelOffset": Vector2(-150.5, 120.5),
		"frontWheelOffset": Vector2(168.5, 120.5),
		"wheelRadius": 120.0,
		"cutoutRadius": 125.0,
		"seatOffset": Vector2(-40.5, -99.5),
		"engineOffset": Vector2(199.5, 0.5),
		"bodySize": Vector2(641, 399),
		"bodyPivot": Vector2(320.5, 199.5),
		"isBike": false,
		"body_image": "res://assets/vehicles/blue_flame_truck/vehicle_body_truck_side.png",
		"wheel_image": "res://assets/vehicles/blue_flame_truck/wheel_rear.png",
		"body_scale": 0.18,
		"rear_wheel_offset": Vector2(-150.5, 120.5),
		"front_wheel_offset": Vector2(168.5, 120.5),
		"wheel_radius": 120.0,
		"cutout_radius": 125.0,
		"seat_offset": Vector2(-40.5, -99.5),
		"engine_offset": Vector2(199.5, 0.5),
		"body_size": Vector2(641, 399),
		"body_pivot": Vector2(320.5, 199.5),
		"is_bike": false,
		"body_burnt_image": "res://assets/vehicles/garage/car_08/body_burnt.png",
		"wheel_burnt_image": "res://assets/vehicles/garage/car_08/wheel_burnt.png",
		"preview_image": "res://assets/vehicles/garage/car_08/car_08.png",
	},
	"orc_racer": {
		"front_weight_ratio": 0.55,
		"rear_weight_ratio": 0.45,

		"base_brake_torque": 8000000.0,
		"base_torque": 14500000.0,
		"air_drag_coeff": 0.014,
		"rolling_resistance": 0.018,
		"center_of_mass": Vector2(0.0, 8.0),
		"wheel_mass": 25.0,
		"driveType": "RWD",
		"drive_type": "RWD",
		"mass": 1300.0,
		"bodyFrequencyHz": 2.0,
		"dampingRatio": 0.7,
		"maxTravel": 0.25,
		"bumpStop": 0.25,
		"reboundLimit": 0.25,
		"body_frequency_hz": 2.0,
		"damping_ratio": 0.7,
		"max_travel": 0.25,
		"bump_stop": 0.25,
		"rebound_limit": 0.25,
		"name": "Orc Racer",
		"bodyImage": "res://assets/vehicles/orc_racer/body.png",
		"wheelImage": "res://assets/vehicles/orc_racer/wheel_rear.png",
		"bodyScale": 0.18,
		"rearWheelOffset": Vector2(-222.5, 111.5),
		"frontWheelOffset": Vector2(211.5, 111.5),
		"wheelRadius": 93.5,
		"cutoutRadius": 98.5,
		"seatOffset": Vector2(-38.0, -100.0),
		"engineOffset": Vector2(-178.0, 0.0),
		"bodySize": Vector2(636, 220),
		"bodyPivot": Vector2(318.0, 110.0),
		"isBike": false,
		"body_image": "res://assets/vehicles/orc_racer/body.png",
		"wheel_image": "res://assets/vehicles/orc_racer/wheel_rear.png",
		"body_scale": 0.18,
		"rear_wheel_offset": Vector2(-222.5, 111.5),
		"front_wheel_offset": Vector2(211.5, 111.5),
		"wheel_radius": 93.5,
		"cutout_radius": 98.5,
		"seat_offset": Vector2(-38.0, -100.0),
		"engine_offset": Vector2(-178.0, 0.0),
		"body_size": Vector2(636, 220),
		"body_pivot": Vector2(318.0, 110.0),
		"is_bike": false
	},
	"trophy_truck": {
		"front_weight_ratio": 0.52,
		"rear_weight_ratio": 0.48,

		"base_brake_torque": 18000000.0,
		"base_torque": 32000000.0,
		"air_drag_coeff": 0.02,
		"rolling_resistance": 0.022,
		"center_of_mass": Vector2(0.0, 2.0),
		"wheel_mass": 45.0,
		"driveType": "AWD",
		"drive_type": "AWD",
		"mass": 2500.0,
		"bodyFrequencyHz": 1.6,
		"dampingRatio": 0.7,
		"maxTravel": 0.35,
		"bumpStop": 0.35,
		"reboundLimit": 0.35,
		"body_frequency_hz": 1.6,
		"damping_ratio": 0.7,
		"max_travel": 0.35,
		"bump_stop": 0.35,
		"rebound_limit": 0.35,
		"name": "Trophy Truck",
		"bodyImage": "res://assets/vehicles/trophy_truck/body.png",
		"wheelImage": "res://assets/vehicles/trophy_truck/wheel.png",
		"bodyScale": 0.18,
		"rearWheelOffset": Vector2(-226.5, 99.5),
		"frontWheelOffset": Vector2(221.5, 99.5),
		"wheelRadius": 60.0,
		"cutoutRadius": 65.0,
		"seatOffset": Vector2(-25.5, -102.0),
		"engineOffset": Vector2(174.5, 23.0),
		"bodySize": Vector2(691, 194),
		"bodyPivot": Vector2(345.5, 97.0),
		"isBike": false,
		"body_image": "res://assets/vehicles/trophy_truck/body.png",
		"wheel_image": "res://assets/vehicles/trophy_truck/wheel.png",
		"body_scale": 0.18,
		"rear_wheel_offset": Vector2(-226.5, 99.5),
		"front_wheel_offset": Vector2(221.5, 99.5),
		"wheel_radius": 60.0,
		"cutout_radius": 65.0,
		"seat_offset": Vector2(-25.5, -102.0),
		"engine_offset": Vector2(174.5, 23.0),
		"body_size": Vector2(691, 194),
		"body_pivot": Vector2(345.5, 97.0),
		"is_bike": false
	},
	"dune_buggy": {
		"front_weight_ratio": 0.55,
		"rear_weight_ratio": 0.45,

		"base_brake_torque": 8000000.0,
		"base_torque": 14500000.0,
		"air_drag_coeff": 0.014,
		"rolling_resistance": 0.018,
		"center_of_mass": Vector2(0.0, 8.0),
		"wheel_mass": 25.0,
		"driveType": "RWD",
		"drive_type": "RWD",
		"mass": 1300.0,
		"bodyFrequencyHz": 2.0,
		"dampingRatio": 0.7,
		"maxTravel": 0.25,
		"bumpStop": 0.25,
		"reboundLimit": 0.25,
		"body_frequency_hz": 2.0,
		"damping_ratio": 0.7,
		"max_travel": 0.25,
		"bump_stop": 0.25,
		"rebound_limit": 0.25,
		"name": "Electric Dune Buggy",
		"bodyImage": "res://assets/vehicles/girl_buggy/body.png",
		"wheelImage": "res://assets/vehicles/girl_buggy/wheel_rear.png",
		"bodyScale": 0.25,
		"rearWheelOffset": Vector2(-116.5, 66.0),
		"frontWheelOffset": Vector2(115.5, 66.0),
		"wheelRadius": 59.0,
		"cutoutRadius": 64.0,
		"seatOffset": Vector2(-19.5, -74.5),
		"engineOffset": Vector2(-119.5, 15.5),
		"bodySize": Vector2(599, 209),
		"bodyPivot": Vector2(299.5, 104.5),
		"isBike": false,
		"body_image": "res://assets/vehicles/girl_buggy/body.png",
		"wheel_image": "res://assets/vehicles/girl_buggy/wheel_rear.png",
		"body_scale": 0.25,
		"rear_wheel_offset": Vector2(-116.5, 66.0),
		"front_wheel_offset": Vector2(115.5, 66.0),
		"wheel_radius": 59.0,
		"cutout_radius": 64.0,
		"seat_offset": Vector2(-19.5, -74.5),
		"engine_offset": Vector2(-119.5, 15.5),
		"body_size": Vector2(599, 209),
		"body_pivot": Vector2(299.5, 104.5),
		"is_bike": false
	},
	"car_01": {
		"front_weight_ratio": 0.55,
		"rear_weight_ratio": 0.45,

		"base_brake_torque": 8000000.0,
		"base_torque": 14500000.0,
		"air_drag_coeff": 0.014,
		"rolling_resistance": 0.018,
		"center_of_mass": Vector2(0.0, 8.0),
		"wheel_mass": 25.0,
		"driveType": "RWD",
		"drive_type": "RWD",
		"mass": 1300.0,
		"bodyFrequencyHz": 2.0,
		"dampingRatio": 0.7,
		"maxTravel": 0.25,
		"bumpStop": 0.25,
		"reboundLimit": 0.25,
		"body_frequency_hz": 2.0,
		"damping_ratio": 0.7,
		"max_travel": 0.25,
		"bump_stop": 0.25,
		"rebound_limit": 0.25,
		"name": "Cartoon Red Hatchback",
		"bodyImage": "res://assets/vehicles/garage/car_01/body.png",
		"wheelImage": "res://assets/vehicles/garage/car_01/wheel.png",
		"bodyScale": 0.4256,
		"rearWheelOffset": Vector2(-138.5, 137.0),
		"frontWheelOffset": Vector2(139.5, 137.0),
		"wheelRadius": 52.5,
		"cutoutRadius": 57.5,
		"seatOffset": Vector2(-30.0, -24.5),
		"engineOffset": Vector2(140.0, 20.5),
		"bodySize": Vector2(470, 259),
		"bodyPivot": Vector2(235.0, 129.5),
		"isBike": false,
		"body_image": "res://assets/vehicles/garage/car_01/body.png",
		"wheel_image": "res://assets/vehicles/garage/car_01/wheel.png",
		"body_scale": 0.4256,
		"rear_wheel_offset": Vector2(-138.5, 137.0),
		"front_wheel_offset": Vector2(139.5, 137.0),
		"wheel_radius": 52.5,
		"cutout_radius": 57.5,
		"seat_offset": Vector2(-30.0, -24.5),
		"engine_offset": Vector2(140.0, 20.5),
		"body_size": Vector2(470, 259),
		"body_pivot": Vector2(235.0, 129.5),
		"is_bike": false
	},
	"car_02": {
		"front_weight_ratio": 0.55,
		"rear_weight_ratio": 0.45,

		"base_brake_torque": 8000000.0,
		"base_torque": 14500000.0,
		"air_drag_coeff": 0.014,
		"rolling_resistance": 0.018,
		"center_of_mass": Vector2(0.0, 8.0),
		"wheel_mass": 25.0,
		"driveType": "RWD",
		"drive_type": "RWD",
		"mass": 1300.0,
		"bodyFrequencyHz": 2.0,
		"dampingRatio": 0.7,
		"maxTravel": 0.25,
		"bumpStop": 0.25,
		"reboundLimit": 0.25,
		"body_frequency_hz": 2.0,
		"damping_ratio": 0.7,
		"max_travel": 0.25,
		"bump_stop": 0.25,
		"rebound_limit": 0.25,
		"name": "Mini Compact City Car",
		"bodyImage": "res://assets/vehicles/garage/car_02/body.png",
		"wheelImage": "res://assets/vehicles/garage/car_02/wheel.png",
		"bodyScale": 0.344,
		"rearWheelOffset": Vector2(-191.5, 124.5),
		"frontWheelOffset": Vector2(179.5, 124.5),
		"wheelRadius": 61.5,
		"cutoutRadius": 66.5,
		"seatOffset": Vector2(-19.0, -23.5),
		"engineOffset": Vector2(161.0, 26.5),
		"bodySize": Vector2(558, 327),
		"bodyPivot": Vector2(279.0, 163.5),
		"isBike": false,
		"body_image": "res://assets/vehicles/garage/car_02/body.png",
		"wheel_image": "res://assets/vehicles/garage/car_02/wheel.png",
		"body_scale": 0.344,
		"rear_wheel_offset": Vector2(-191.5, 124.5),
		"front_wheel_offset": Vector2(179.5, 124.5),
		"wheel_radius": 61.5,
		"cutout_radius": 66.5,
		"seat_offset": Vector2(-19.0, -23.5),
		"engine_offset": Vector2(161.0, 26.5),
		"body_size": Vector2(558, 327),
		"body_pivot": Vector2(279.0, 163.5),
		"is_bike": false
	},
	"car_04": {
		"front_weight_ratio": 0.52,
		"rear_weight_ratio": 0.48,

		"base_brake_torque": 18000000.0,
		"base_torque": 32000000.0,
		"air_drag_coeff": 0.02,
		"rolling_resistance": 0.022,
		"center_of_mass": Vector2(0.0, 2.0),
		"wheel_mass": 45.0,
		"driveType": "AWD",
		"drive_type": "AWD",
		"mass": 2500.0,
		"bodyFrequencyHz": 1.6,
		"dampingRatio": 0.7,
		"maxTravel": 0.35,
		"bumpStop": 0.35,
		"reboundLimit": 0.35,
		"body_frequency_hz": 1.6,
		"damping_ratio": 0.7,
		"max_travel": 0.35,
		"bump_stop": 0.35,
		"rebound_limit": 0.35,
		"name": "SWAT Armored Heavy Van",
		"bodyImage": "res://assets/vehicles/garage/car_04/body.png",
		"wheelImage": "res://assets/vehicles/garage/car_04/wheel.png",
		"bodyScale": 0.1318,
		"rearWheelOffset": Vector2(-554.5, 390.0),
		"frontWheelOffset": Vector2(570.5, 390.0),
		"wheelRadius": 141.0,
		"cutoutRadius": 146.0,
		"seatOffset": Vector2(-95.5, -80.0),
		"engineOffset": Vector2(554.5, 80.0),
		"bodySize": Vector2(1791, 800),
		"bodyPivot": Vector2(895.5, 400.0),
		"isBike": false,
		"body_image": "res://assets/vehicles/garage/car_04/body.png",
		"wheel_image": "res://assets/vehicles/garage/car_04/wheel.png",
		"body_scale": 0.1318,
		"rear_wheel_offset": Vector2(-554.5, 390.0),
		"front_wheel_offset": Vector2(570.5, 390.0),
		"wheel_radius": 141.0,
		"cutout_radius": 146.0,
		"seat_offset": Vector2(-95.5, -80.0),
		"engine_offset": Vector2(554.5, 80.0),
		"body_size": Vector2(1791, 800),
		"body_pivot": Vector2(895.5, 400.0),
		"is_bike": false
	},
	"car_06": {
		"front_weight_ratio": 0.52,
		"rear_weight_ratio": 0.48,

		"base_brake_torque": 18000000.0,
		"base_torque": 32000000.0,
		"air_drag_coeff": 0.02,
		"rolling_resistance": 0.022,
		"center_of_mass": Vector2(0.0, 2.0),
		"wheel_mass": 45.0,
		"driveType": "AWD",
		"drive_type": "AWD",
		"mass": 2500.0,
		"bodyFrequencyHz": 1.6,
		"dampingRatio": 0.7,
		"maxTravel": 0.35,
		"bumpStop": 0.35,
		"reboundLimit": 0.35,
		"body_frequency_hz": 1.6,
		"damping_ratio": 0.7,
		"max_travel": 0.35,
		"bump_stop": 0.35,
		"rebound_limit": 0.35,
		"name": "Ice Cream Novelty Van",
		"bodyImage": "res://assets/vehicles/garage/car_06/body.png",
		"wheelImage": "res://assets/vehicles/garage/car_06/wheel.png",
		"bodyScale": 0.2335,
		"rearWheelOffset": Vector2(-263.5, 456.0),
		"frontWheelOffset": Vector2(215.5, 457.0),
		"wheelRadius": 108.5,
		"cutoutRadius": 113.5,
		"seatOffset": Vector2(80.0, 119.5),
		"engineOffset": Vector2(260.0, 279.5),
		"bodySize": Vector2(830, 973),
		"bodyPivot": Vector2(415.0, 486.5),
		"isBike": false,
		"body_image": "res://assets/vehicles/garage/car_06/body.png",
		"wheel_image": "res://assets/vehicles/garage/car_06/wheel.png",
		"body_scale": 0.2335,
		"rear_wheel_offset": Vector2(-263.5, 456.0),
		"front_wheel_offset": Vector2(215.5, 457.0),
		"wheel_radius": 108.5,
		"cutout_radius": 113.5,
		"seat_offset": Vector2(80.0, 119.5),
		"engine_offset": Vector2(260.0, 279.5),
		"body_size": Vector2(830, 973),
		"body_pivot": Vector2(415.0, 486.5),
		"is_bike": false
	},
	"car_07": {
		"front_weight_ratio": 0.52,
		"rear_weight_ratio": 0.48,

		"base_brake_torque": 18000000.0,
		"base_torque": 32000000.0,
		"air_drag_coeff": 0.02,
		"rolling_resistance": 0.022,
		"center_of_mass": Vector2(0.0, 2.0),
		"wheel_mass": 45.0,
		"driveType": "AWD",
		"drive_type": "AWD",
		"mass": 2500.0,
		"bodyFrequencyHz": 1.6,
		"dampingRatio": 0.7,
		"maxTravel": 0.35,
		"bumpStop": 0.35,
		"reboundLimit": 0.35,
		"body_frequency_hz": 1.6,
		"damping_ratio": 0.7,
		"max_travel": 0.35,
		"bump_stop": 0.35,
		"rebound_limit": 0.35,
		"name": "Cartoon Emergency Ambulance",
		"bodyImage": "res://assets/vehicles/garage/car_07/body.png",
		"wheelImage": "res://assets/vehicles/garage/car_07/wheel.png",
		"bodyScale": 0.2864,
		"rearWheelOffset": Vector2(-152.9, 118.0),
		"frontWheelOffset": Vector2(257.0, 118.0),
		"wheelRadius": 44.0,
		"cutoutRadius": 49.0,
		"seatOffset": Vector2(50.0, -40.0),
		"engineOffset": Vector2(260.0, 20.0),
		"bodySize": Vector2(740, 336),
		"bodyPivot": Vector2(370.0, 168.0),
		"isBike": false,
		"body_image": "res://assets/vehicles/garage/car_07/body.png",
		"wheel_image": "res://assets/vehicles/garage/car_07/wheel.png",
		"body_scale": 0.2864,
		"rear_wheel_offset": Vector2(-152.9, 118.0),
		"front_wheel_offset": Vector2(257.0, 118.0),
		"wheel_radius": 44.0,
		"cutout_radius": 49.0,
		"seat_offset": Vector2(50.0, -40.0),
		"engine_offset": Vector2(260.0, 20.0),
		"body_size": Vector2(740, 336),
		"body_pivot": Vector2(370.0, 168.0),
		"is_bike": false
	},
	"car_08": {
		"front_weight_ratio": 0.5,
		"rear_weight_ratio": 0.5,

		"base_brake_torque": 48000000.0,
		"base_torque": 85000000.0,
		"air_drag_coeff": 0.035,
		"rolling_resistance": 0.028,
		"center_of_mass": Vector2(0.0, -12.0),
		"wheel_mass": 160.0,
		"driveType": "AWD",
		"drive_type": "AWD",
		"mass": 5000.0,
		"bodyFrequencyHz": 1.4,
		"dampingRatio": 0.75,
		"maxTravel": 0.4,
		"bumpStop": 0.4,
		"reboundLimit": 0.4,
		"body_frequency_hz": 1.4,
		"damping_ratio": 0.75,
		"max_travel": 0.4,
		"bump_stop": 0.4,
		"rebound_limit": 0.4,
		"name": "Bigfoot Heavy Monster Truck",
		"bodyImage": "res://assets/vehicles/garage/car_08/body.png",
		"wheelImage": "res://assets/vehicles/garage/car_08/wheel.png",
		"bodyScale": 0.0903,
		"rearWheelOffset": Vector2(-709.0, 283.0),
		"frontWheelOffset": Vector2(687.0, 283.0),
		"wheelRadius": 370.0,
		"cutoutRadius": 375.0,
		"seatOffset": Vector2(-150.0, -220.0),
		"engineOffset": Vector2(-442.0, -353.0),
		"bodySize": Vector2(2258, 1310),
		"bodyPivot": Vector2(1129.0, 655.0),
		"isBike": false,
		"body_image": "res://assets/vehicles/garage/car_08/body.png",
		"wheel_image": "res://assets/vehicles/garage/car_08/wheel.png",
		"body_scale": 0.0903,
		"rear_wheel_offset": Vector2(-709.0, 283.0),
		"front_wheel_offset": Vector2(687.0, 283.0),
		"wheel_radius": 370.0,
		"cutout_radius": 375.0,
		"seat_offset": Vector2(-150.0, -220.0),
		"engine_offset": Vector2(-442.0, -353.0),
		"body_size": Vector2(2258, 1310),
		"body_pivot": Vector2(1129.0, 655.0),
		"is_bike": false
	},
	"car_10": {
		"front_weight_ratio": 0.52,
		"rear_weight_ratio": 0.48,

		"base_brake_torque": 18000000.0,
		"base_torque": 32000000.0,
		"air_drag_coeff": 0.02,
		"rolling_resistance": 0.022,
		"center_of_mass": Vector2(0.0, 2.0),
		"wheel_mass": 45.0,
		"driveType": "AWD",
		"drive_type": "AWD",
		"mass": 2500.0,
		"bodyFrequencyHz": 1.6,
		"dampingRatio": 0.7,
		"maxTravel": 0.35,
		"bumpStop": 0.35,
		"reboundLimit": 0.35,
		"body_frequency_hz": 1.6,
		"damping_ratio": 0.7,
		"max_travel": 0.35,
		"bump_stop": 0.35,
		"rebound_limit": 0.35,
		"name": "Combat Armored Humvee",
		"bodyImage": "res://assets/vehicles/garage/car_10/body.png",
		"wheelImage": "res://assets/vehicles/garage/car_10/wheel.png",
		"bodyScale": 0.2898,
		"rearWheelOffset": Vector2(-271.0, 159.0),
		"frontWheelOffset": Vector2(251.0, 159.0),
		"wheelRadius": 85.5,
		"cutoutRadius": 90.5,
		"seatOffset": Vector2(-59.5, -38.0),
		"engineOffset": Vector2(240.5, 32.0),
		"bodySize": Vector2(759, 376),
		"bodyPivot": Vector2(379.5, 188.0),
		"isBike": false,
		"body_image": "res://assets/vehicles/garage/car_10/body.png",
		"wheel_image": "res://assets/vehicles/garage/car_10/wheel.png",
		"body_scale": 0.2898,
		"rear_wheel_offset": Vector2(-271.0, 159.0),
		"front_wheel_offset": Vector2(251.0, 159.0),
		"wheel_radius": 85.5,
		"cutout_radius": 90.5,
		"seat_offset": Vector2(-59.5, -38.0),
		"engine_offset": Vector2(240.5, 32.0),
		"body_size": Vector2(759, 376),
		"body_pivot": Vector2(379.5, 188.0),
		"is_bike": false
	},
	"car_11": {
		"front_weight_ratio": 0.52,
		"rear_weight_ratio": 0.48,

		"base_brake_torque": 18000000.0,
		"base_torque": 32000000.0,
		"air_drag_coeff": 0.02,
		"rolling_resistance": 0.022,
		"center_of_mass": Vector2(0.0, 2.0),
		"wheel_mass": 45.0,
		"driveType": "AWD",
		"drive_type": "AWD",
		"mass": 2500.0,
		"bodyFrequencyHz": 1.6,
		"dampingRatio": 0.7,
		"maxTravel": 0.35,
		"bumpStop": 0.35,
		"reboundLimit": 0.35,
		"body_frequency_hz": 1.6,
		"damping_ratio": 0.7,
		"max_travel": 0.35,
		"bump_stop": 0.35,
		"rebound_limit": 0.35,
		"name": "HillClimb Monster Beast 4x4",
		"bodyImage": "res://assets/vehicles/garage/car_11/body.png",
		"wheelImage": "res://assets/vehicles/garage/car_11/wheel.png",
		"bodyScale": 0.2317,
		"rearWheelOffset": Vector2(-181.0, 179.5),
		"frontWheelOffset": Vector2(201.0, 179.5),
		"wheelRadius": 120.5,
		"cutoutRadius": 125.5,
		"seatOffset": Vector2(-40.5, -59.5),
		"engineOffset": Vector2(179.5, 10.5),
		"bodySize": Vector2(641, 399),
		"bodyPivot": Vector2(320.5, 199.5),
		"isBike": false,
		"body_image": "res://assets/vehicles/garage/car_11/body.png",
		"wheel_image": "res://assets/vehicles/garage/car_11/wheel.png",
		"body_scale": 0.2317,
		"rear_wheel_offset": Vector2(-181.0, 179.5),
		"front_wheel_offset": Vector2(201.0, 179.5),
		"wheel_radius": 120.5,
		"cutout_radius": 125.5,
		"seat_offset": Vector2(-40.5, -59.5),
		"engine_offset": Vector2(179.5, 10.5),
		"body_size": Vector2(641, 399),
		"body_pivot": Vector2(320.5, 199.5),
		"is_bike": false
	},
	"car_18": {
		"front_weight_ratio": 0.55,
		"rear_weight_ratio": 0.45,

		"base_brake_torque": 8000000.0,
		"base_torque": 14500000.0,
		"air_drag_coeff": 0.014,
		"rolling_resistance": 0.018,
		"center_of_mass": Vector2(0.0, 8.0),
		"wheel_mass": 25.0,
		"driveType": "RWD",
		"drive_type": "RWD",
		"mass": 1300.0,
		"bodyFrequencyHz": 2.0,
		"dampingRatio": 0.7,
		"maxTravel": 0.25,
		"bumpStop": 0.25,
		"reboundLimit": 0.25,
		"body_frequency_hz": 2.0,
		"damping_ratio": 0.7,
		"max_travel": 0.25,
		"bump_stop": 0.25,
		"rebound_limit": 0.25,
		"name": "Convertible Roadster Mini",
		"bodyImage": "res://assets/vehicles/garage/car_18/body.png",
		"wheelImage": "res://assets/vehicles/garage/car_18/wheel.png",
		"bodyScale": 0.35,
		"rearWheelOffset": Vector2(-190.5, 86.0),
		"frontWheelOffset": Vector2(180.5, 86.0),
		"wheelRadius": 61.5,
		"cutoutRadius": 66.5,
		"seatOffset": Vector2(-40.0, -30.0),
		"engineOffset": Vector2(160.0, 20.0),
		"bodySize": Vector2(560, 250),
		"bodyPivot": Vector2(280.0, 125.0),
		"isBike": false,
		"body_image": "res://assets/vehicles/garage/car_18/body.png",
		"wheel_image": "res://assets/vehicles/garage/car_18/wheel.png",
		"body_scale": 0.35,
		"rear_wheel_offset": Vector2(-190.5, 86.0),
		"front_wheel_offset": Vector2(180.5, 86.0),
		"wheel_radius": 61.5,
		"cutout_radius": 66.5,
		"seat_offset": Vector2(-40.0, -30.0),
		"engine_offset": Vector2(160.0, 20.0),
		"body_size": Vector2(560, 250),
		"body_pivot": Vector2(280.0, 125.0),
		"is_bike": false
	},
	"car_19": {
		"front_weight_ratio": 0.55,
		"rear_weight_ratio": 0.45,

		"base_brake_torque": 8000000.0,
		"base_torque": 14500000.0,
		"air_drag_coeff": 0.014,
		"rolling_resistance": 0.018,
		"center_of_mass": Vector2(0.0, 8.0),
		"wheel_mass": 25.0,
		"driveType": "RWD",
		"drive_type": "RWD",
		"mass": 1300.0,
		"bodyFrequencyHz": 2.0,
		"dampingRatio": 0.7,
		"maxTravel": 0.25,
		"bumpStop": 0.25,
		"reboundLimit": 0.25,
		"body_frequency_hz": 2.0,
		"damping_ratio": 0.7,
		"max_travel": 0.25,
		"bump_stop": 0.25,
		"rebound_limit": 0.25,
		"name": "Off-Road Spiked Beast Buggy",
		"bodyImage": "res://assets/vehicles/garage/car_19/body.png",
		"wheelImage": "res://assets/vehicles/garage/car_19/wheel.png",
		"bodyScale": 0.2987,
		"rearWheelOffset": Vector2(-194.5, 102.5),
		"frontWheelOffset": Vector2(221.5, 103.5),
		"wheelRadius": 93.5,
		"cutoutRadius": 98.5,
		"seatOffset": Vector2(-28.0, -30.0),
		"engineOffset": Vector2(-98.0, 10.0),
		"bodySize": Vector2(636, 220),
		"bodyPivot": Vector2(318.0, 110.0),
		"isBike": false,
		"body_image": "res://assets/vehicles/garage/car_19/body.png",
		"wheel_image": "res://assets/vehicles/garage/car_19/wheel.png",
		"body_scale": 0.2987,
		"rear_wheel_offset": Vector2(-194.5, 102.5),
		"front_wheel_offset": Vector2(221.5, 103.5),
		"wheel_radius": 93.5,
		"cutout_radius": 98.5,
		"seat_offset": Vector2(-28.0, -30.0),
		"engine_offset": Vector2(-98.0, 10.0),
		"body_size": Vector2(636, 220),
		"body_pivot": Vector2(318.0, 110.0),
		"is_bike": false
	},
	"car_14": {
		"front_weight_ratio": 0.4,
		"rear_weight_ratio": 0.6,

		"base_brake_torque": 1600000.0,
		"base_torque": 2600000.0,
		"air_drag_coeff": 0.008,
		"rolling_resistance": 0.015,
		"center_of_mass": Vector2(0.0, 10.0),
		"wheel_mass": 10.0,
		"driveType": "RWD",
		"drive_type": "RWD",
		"mass": 200.0,
		"bodyFrequencyHz": 2.6,
		"dampingRatio": 0.65,
		"maxTravel": 0.2,
		"bumpStop": 0.2,
		"reboundLimit": 0.2,
		"body_frequency_hz": 2.6,
		"damping_ratio": 0.65,
		"max_travel": 0.2,
		"bump_stop": 0.2,
		"rebound_limit": 0.2,
		"name": "Super Sport Racing Superbike",
		"bodyImage": "res://assets/vehicles/garage/car_14/body.png",
		"wheelImage": "res://assets/vehicles/garage/car_14/wheel.png",
		"bodyScale": 0.1991,
		"rearWheelOffset": Vector2(-213.0, 144.0),
		"frontWheelOffset": Vector2(337.0, 144.0),
		"wheelRadius": 128.0,
		"cutoutRadius": 128.0,
		"seatOffset": Vector2(-58.0, -41.0),
		"engineOffset": Vector2(22.0, 39.0),
		"bodySize": Vector2(796, 422),
		"bodyPivot": Vector2(398.0, 211.0),
		"isBike": true,
		"body_image": "res://assets/vehicles/garage/car_14/body.png",
		"wheel_image": "res://assets/vehicles/garage/car_14/wheel.png",
		"body_scale": 0.1991,
		"rear_wheel_offset": Vector2(-213.0, 144.0),
		"front_wheel_offset": Vector2(337.0, 144.0),
		"wheel_radius": 128.0,
		"cutout_radius": 128.0,
		"seat_offset": Vector2(-58.0, -41.0),
		"engine_offset": Vector2(22.0, 39.0),
		"body_size": Vector2(796, 422),
		"body_pivot": Vector2(398.0, 211.0),
		"is_bike": true
	},
	"car_15": {
		"front_weight_ratio": 0.4,
		"rear_weight_ratio": 0.6,

		"base_brake_torque": 2300000.0,
		"base_torque": 3800000.0,
		"air_drag_coeff": 0.01,
		"rolling_resistance": 0.016,
		"center_of_mass": Vector2(0.0, 9.0),
		"wheel_mass": 14.0,
		"driveType": "RWD",
		"drive_type": "RWD",
		"mass": 300.0,
		"bodyFrequencyHz": 1.8,
		"dampingRatio": 0.7,
		"maxTravel": 0.25,
		"bumpStop": 0.25,
		"reboundLimit": 0.25,
		"body_frequency_hz": 1.8,
		"damping_ratio": 0.7,
		"max_travel": 0.25,
		"bump_stop": 0.25,
		"rebound_limit": 0.25,
		"name": "Custom Chopper Beast",
		"bodyImage": "res://assets/vehicles/garage/car_15/body.png",
		"wheelImage": "res://assets/vehicles/garage/car_15/wheel.png",
		"bodyScale": 0.1778,
		"rearWheelOffset": Vector2(-353.5, 151.0),
		"frontWheelOffset": Vector2(397.0, 151.0),
		"wheelRadius": 132.5,
		"cutoutRadius": 132.5,
		"seatOffset": Vector2(-96.0, -18.0),
		"engineOffset": Vector2(84.0, 42.0),
		"bodySize": Vector2(972, 396),
		"bodyPivot": Vector2(486.0, 198.0),
		"isBike": true,
		"body_image": "res://assets/vehicles/garage/car_15/body.png",
		"wheel_image": "res://assets/vehicles/garage/car_15/wheel.png",
		"body_scale": 0.1778,
		"rear_wheel_offset": Vector2(-353.5, 151.0),
		"front_wheel_offset": Vector2(397.0, 151.0),
		"wheel_radius": 132.5,
		"cutout_radius": 132.5,
		"seat_offset": Vector2(-96.0, -18.0),
		"engine_offset": Vector2(84.0, 42.0),
		"body_size": Vector2(972, 396),
		"body_pivot": Vector2(486.0, 198.0),
		"is_bike": true
	},
	"car_16": {
		"front_weight_ratio": 0.4,
		"rear_weight_ratio": 0.6,

		"base_brake_torque": 1600000.0,
		"base_torque": 2600000.0,
		"air_drag_coeff": 0.008,
		"rolling_resistance": 0.015,
		"center_of_mass": Vector2(0.0, 10.0),
		"wheel_mass": 10.0,
		"driveType": "RWD",
		"drive_type": "RWD",
		"mass": 200.0,
		"bodyFrequencyHz": 2.6,
		"dampingRatio": 0.65,
		"maxTravel": 0.2,
		"bumpStop": 0.2,
		"reboundLimit": 0.2,
		"body_frequency_hz": 2.6,
		"damping_ratio": 0.65,
		"max_travel": 0.2,
		"bump_stop": 0.2,
		"rebound_limit": 0.2,
		"name": "Off-Road Motocross Dirt Bike",
		"bodyImage": "res://assets/vehicles/garage/car_16/body.png",
		"wheelImage": "res://assets/vehicles/garage/car_16/wheel.png",
		"bodyScale": 0.2004,
		"rearWheelOffset": Vector2(-225.5, 154.5),
		"frontWheelOffset": Vector2(275.5, 154.5),
		"wheelRadius": 137.5,
		"cutoutRadius": 137.5,
		"seatOffset": Vector2(-40.5, -53.5),
		"engineOffset": Vector2(29.5, 36.5),
		"bodySize": Vector2(721, 367),
		"bodyPivot": Vector2(360.5, 183.5),
		"isBike": true,
		"body_image": "res://assets/vehicles/garage/car_16/body.png",
		"wheel_image": "res://assets/vehicles/garage/car_16/wheel.png",
		"body_scale": 0.2004,
		"rear_wheel_offset": Vector2(-225.5, 154.5),
		"front_wheel_offset": Vector2(275.5, 154.5),
		"wheel_radius": 137.5,
		"cutout_radius": 137.5,
		"seat_offset": Vector2(-40.5, -53.5),
		"engine_offset": Vector2(29.5, 36.5),
		"body_size": Vector2(721, 367),
		"body_pivot": Vector2(360.5, 183.5),
		"is_bike": true
	},
	"car_17": {
		"front_weight_ratio": 0.4,
		"rear_weight_ratio": 0.6,

		"base_brake_torque": 1600000.0,
		"base_torque": 2600000.0,
		"air_drag_coeff": 0.008,
		"rolling_resistance": 0.015,
		"center_of_mass": Vector2(0.0, 10.0),
		"wheel_mass": 10.0,
		"driveType": "RWD",
		"drive_type": "RWD",
		"mass": 200.0,
		"bodyFrequencyHz": 2.6,
		"dampingRatio": 0.65,
		"maxTravel": 0.2,
		"bumpStop": 0.2,
		"reboundLimit": 0.2,
		"body_frequency_hz": 2.6,
		"damping_ratio": 0.65,
		"max_travel": 0.2,
		"bump_stop": 0.2,
		"rebound_limit": 0.2,
		"name": "Streetfighter Naked Bike",
		"bodyImage": "res://assets/vehicles/garage/car_17/body.png",
		"wheelImage": "res://assets/vehicles/garage/car_17/wheel.png",
		"bodyScale": 0.1888,
		"rearWheelOffset": Vector2(-281.5, 164.5),
		"frontWheelOffset": Vector2(323.5, 164.5),
		"wheelRadius": 127.5,
		"cutoutRadius": 127.5,
		"seatOffset": Vector2(-59.5, -40.5),
		"engineOffset": Vector2(40.5, 39.5),
		"bodySize": Vector2(839, 421),
		"bodyPivot": Vector2(419.5, 210.5),
		"isBike": true,
		"body_image": "res://assets/vehicles/garage/car_17/body.png",
		"wheel_image": "res://assets/vehicles/garage/car_17/wheel.png",
		"body_scale": 0.1888,
		"rear_wheel_offset": Vector2(-281.5, 164.5),
		"front_wheel_offset": Vector2(323.5, 164.5),
		"wheel_radius": 127.5,
		"cutout_radius": 127.5,
		"seat_offset": Vector2(-59.5, -40.5),
		"engine_offset": Vector2(40.5, 39.5),
		"body_size": Vector2(839, 421),
		"body_pivot": Vector2(419.5, 210.5),
		"is_bike": true
	},
	"car_24": {
		"front_weight_ratio": 0.4,
		"rear_weight_ratio": 0.6,

		"base_brake_torque": 2800000.0,
		"base_torque": 4600000.0,
		"air_drag_coeff": 0.012,
		"rolling_resistance": 0.018,
		"center_of_mass": Vector2(0.0, 8.0),
		"wheel_mass": 16.0,
		"driveType": "RWD",
		"drive_type": "RWD",
		"mass": 380.0,
		"bodyFrequencyHz": 1.8,
		"dampingRatio": 0.7,
		"maxTravel": 0.25,
		"bumpStop": 0.25,
		"reboundLimit": 0.25,
		"body_frequency_hz": 1.8,
		"damping_ratio": 0.7,
		"max_travel": 0.25,
		"bump_stop": 0.25,
		"rebound_limit": 0.25,
		"name": "Highway Touring Cruiser",
		"bodyImage": "res://assets/vehicles/garage/car_24/body.png",
		"wheelImage": "res://assets/vehicles/garage/car_24/wheel.png",
		"bodyScale": 0.1982,
		"rearWheelOffset": Vector2(-281.0, 214.5),
		"frontWheelOffset": Vector2(345.0, 214.5),
		"wheelRadius": 108.5,
		"cutoutRadius": 108.5,
		"seatOffset": Vector2(-77.0, -25.5),
		"engineOffset": Vector2(63.0, 64.5),
		"bodySize": Vector2(854, 511),
		"bodyPivot": Vector2(427.0, 255.5),
		"isBike": true,
		"body_image": "res://assets/vehicles/garage/car_24/body.png",
		"wheel_image": "res://assets/vehicles/garage/car_24/wheel.png",
		"body_scale": 0.1982,
		"rear_wheel_offset": Vector2(-281.0, 214.5),
		"front_wheel_offset": Vector2(345.0, 214.5),
		"wheel_radius": 108.5,
		"cutout_radius": 108.5,
		"seat_offset": Vector2(-77.0, -25.5),
		"engine_offset": Vector2(63.0, 64.5),
		"body_size": Vector2(854, 511),
		"body_pivot": Vector2(427.0, 255.5),
		"is_bike": true
	},
	"car_25": {
		"front_weight_ratio": 0.4,
		"rear_weight_ratio": 0.6,

		"base_brake_torque": 2300000.0,
		"base_torque": 3800000.0,
		"air_drag_coeff": 0.01,
		"rolling_resistance": 0.016,
		"center_of_mass": Vector2(0.0, 9.0),
		"wheel_mass": 14.0,
		"driveType": "RWD",
		"drive_type": "RWD",
		"mass": 300.0,
		"bodyFrequencyHz": 1.8,
		"dampingRatio": 0.7,
		"maxTravel": 0.25,
		"bumpStop": 0.25,
		"reboundLimit": 0.25,
		"body_frequency_hz": 1.8,
		"damping_ratio": 0.7,
		"max_travel": 0.25,
		"bump_stop": 0.25,
		"rebound_limit": 0.25,
		"name": "Urban City Commuter Bike",
		"bodyImage": "res://assets/vehicles/garage/car_25/body.png",
		"wheelImage": "res://assets/vehicles/garage/car_25/wheel.png",
		"bodyScale": 0.1841,
		"rearWheelOffset": Vector2(-245.5, 106.0),
		"frontWheelOffset": Vector2(347.5, 106.0),
		"wheelRadius": 120.5,
		"cutoutRadius": 120.5,
		"seatOffset": Vector2(-60.5, -54.0),
		"engineOffset": Vector2(39.5, 26.0),
		"bodySize": Vector2(841, 348),
		"bodyPivot": Vector2(420.5, 174.0),
		"isBike": true,
		"body_image": "res://assets/vehicles/garage/car_25/body.png",
		"wheel_image": "res://assets/vehicles/garage/car_25/wheel.png",
		"body_scale": 0.1841,
		"rear_wheel_offset": Vector2(-245.5, 106.0),
		"front_wheel_offset": Vector2(347.5, 106.0),
		"wheel_radius": 120.5,
		"cutout_radius": 120.5,
		"seat_offset": Vector2(-60.5, -54.0),
		"engine_offset": Vector2(39.5, 26.0),
		"body_size": Vector2(841, 348),
		"body_pivot": Vector2(420.5, 174.0),
		"is_bike": true
	},
}

const BIGFOOT_CONFIG: Dictionary = VEHICLE_CONFIGS["car_08"]

const VEHICLES: Dictionary = {
	"blue_flame_truck": {
		"front_weight_ratio": 0.52,
		"rear_weight_ratio": 0.48,

		"id": "blue_flame_truck",
		"display_name": "Blue Flame Truck",
		"description": "Heavy off-road powerhouse with custom flame side panels, chrome rims, and roaring engine torque.",
		"scene_path": "res://scenes/vehicle/BlueFlameTruck.tscn",
		"preview_path": "res://assets/vehicles/blue_flame_truck/vehicle_assembled_preview.png",
		"unlock_cost": 0,
		"mass": 2500.0,
		"stat_ratings": {
			"power": 5,
			"grip": 4,
			"suspension": 4,
			"fuel": 4
		}
	},
	"orc_racer": {
		"front_weight_ratio": 0.55,
		"rear_weight_ratio": 0.45,

		"id": "orc_racer",
		"display_name": "Orc Racer",
		"description": "Aggressive, high-revving wasteland buggy built for rapid sprints and wild air stunt flips.",
		"scene_path": "res://scenes/vehicle/OrcRacer.tscn",
		"preview_path": "res://assets/vehicles/orc_racer/assembled_preview.png",
		"unlock_cost": 350,
		"mass": 1300.0,
		"stat_ratings": {
			"power": 4,
			"grip": 4,
			"suspension": 4,
			"fuel": 3
		}
	},
	"trophy_truck": {
		"front_weight_ratio": 0.52,
		"rear_weight_ratio": 0.48,

		"id": "trophy_truck",
		"display_name": "Trophy Truck",
		"description": "Desert baja racing machine with extended suspension travel and superior rugged endurance.",
		"scene_path": "res://scenes/vehicle/TrophyTruck.tscn",
		"preview_path": "res://assets/vehicles/trophy_truck/assembled.png",
		"unlock_cost": 500,
		"mass": 2500.0,
		"stat_ratings": {
			"power": 4,
			"grip": 4,
			"suspension": 5,
			"fuel": 4
		}
	},
	"dune_buggy": {
		"front_weight_ratio": 0.55,
		"rear_weight_ratio": 0.45,

		"id": "dune_buggy",
		"display_name": "Electric Dune Buggy",
		"description": "Ultralight tubular roll-cage racer built for agile airtime, rapid tilts, and stunt flips.",
		"scene_path": "res://scenes/vehicle/DuneBuggy.tscn",
		"preview_path": "res://assets/vehicles/alternate/girl_buggy/assembled_preview.png",
		"unlock_cost": 450,
		"mass": 1300.0,
		"stat_ratings": {
			"power": 4,
			"grip": 4,
			"suspension": 4,
			"fuel": 4
		}
	},
	"car_01": {
		"front_weight_ratio": 0.55,
		"rear_weight_ratio": 0.45,

		"id": "car_01",
		"display_name": "Cartoon Red Hatchback",
		"description": "Reliable red starter hatchback with balanced weight, responsive handling, and steady fuel economy.",
		"scene_path": "res://scenes/vehicle/garage/car_01.tscn",
		"preview_path": "res://assets/vehicles/garage/car_01/car_01.png",
		"unlock_cost": 0,
		"mass": 1300.0,
		"stat_ratings": {
			"power": 3,
			"grip": 4,
			"suspension": 3,
			"fuel": 4
		}
	},
	"car_02": {
		"front_weight_ratio": 0.55,
		"rear_weight_ratio": 0.45,

		"id": "car_02",
		"display_name": "Mini Compact City Car",
		"description": "Ultra-agile city cruiser with short wheelbase and quick acceleration, ideal for tight slopes.",
		"scene_path": "res://scenes/vehicle/garage/car_02.tscn",
		"preview_path": "res://assets/vehicles/garage/car_02/car_02.png",
		"unlock_cost": 100,
		"mass": 1300.0,
		"stat_ratings": {
			"power": 3,
			"grip": 4,
			"suspension": 3,
			"fuel": 4
		}
	},
	"car_04": {
		"front_weight_ratio": 0.52,
		"rear_weight_ratio": 0.48,

		"id": "car_04",
		"display_name": "SWAT Armored Heavy Van",
		"description": "Reinforced heavy tactical vehicle with high stability, impact resistance, and crushing torque.",
		"scene_path": "res://scenes/vehicle/garage/car_04.tscn",
		"preview_path": "res://assets/vehicles/garage/car_04/car_04.png",
		"unlock_cost": 400,
		"mass": 2500.0,
		"stat_ratings": {
			"power": 5,
			"grip": 4,
			"suspension": 4,
			"fuel": 4
		}
	},
	"car_06": {
		"front_weight_ratio": 0.52,
		"rear_weight_ratio": 0.48,

		"id": "car_06",
		"display_name": "Ice Cream Novelty Van",
		"description": "Fun high-roof novelty van with joyful bouncy suspension and cheerful retro vibes.",
		"scene_path": "res://scenes/vehicle/garage/car_06.tscn",
		"preview_path": "res://assets/vehicles/garage/car_06/car_06.png",
		"unlock_cost": 200,
		"mass": 2500.0,
		"stat_ratings": {
			"power": 3,
			"grip": 3,
			"suspension": 4,
			"fuel": 4
		}
	},
	"car_07": {
		"front_weight_ratio": 0.52,
		"rear_weight_ratio": 0.48,

		"id": "car_07",
		"display_name": "Cartoon Emergency Ambulance",
		"description": "Emergency vehicle tuned for rapid rescue sprints and high-friction mountain response.",
		"scene_path": "res://scenes/vehicle/garage/car_07.tscn",
		"preview_path": "res://assets/vehicles/garage/car_07/car_07.png",
		"unlock_cost": 350,
		"mass": 2500.0,
		"stat_ratings": {
			"power": 4,
			"grip": 5,
			"suspension": 4,
			"fuel": 4
		}
	},
	"car_08": {
		"front_weight_ratio": 0.5,
		"rear_weight_ratio": 0.5,

		"id": "car_08",
		"display_name": "Bigfoot Heavy Monster Truck",
		"description": "Massive 4x4 monster with giant tires that crush rocky terrain and roll over steep obstacles with ease.",
		"scene_path": "res://scenes/vehicle/garage/car_08.tscn",
		"preview_path": "res://assets/vehicles/garage/car_08/car_08.png",
		"unlock_cost": 600,
		"mass": 5000.0,
		"truck_config": BIGFOOT_CONFIG,
		"stat_ratings": {
			"power": 5,
			"grip": 5,
			"suspension": 5,
			"fuel": 3
		}
	},
	"car_10": {
		"front_weight_ratio": 0.52,
		"rear_weight_ratio": 0.48,

		"id": "car_10",
		"display_name": "Combat Armored Humvee",
		"description": "Military-grade combat all-terrain vehicle featuring all-wheel drive stability and heavy-duty chassis.",
		"scene_path": "res://scenes/vehicle/garage/car_10.tscn",
		"preview_path": "res://assets/vehicles/garage/car_10/car_10.png",
		"unlock_cost": 500,
		"mass": 2500.0,
		"stat_ratings": {
			"power": 4,
			"grip": 5,
			"suspension": 4,
			"fuel": 4
		}
	},
	"car_11": {
		"front_weight_ratio": 0.52,
		"rear_weight_ratio": 0.48,

		"id": "car_11",
		"display_name": "HillClimb Monster Beast 4x4",
		"description": "Wild lifted off-road beast with extreme suspension travel for massive hill leaps.",
		"scene_path": "res://scenes/vehicle/garage/car_11.tscn",
		"preview_path": "res://assets/vehicles/garage/car_11/car_11.png",
		"unlock_cost": 450,
		"mass": 2500.0,
		"stat_ratings": {
			"power": 4,
			"grip": 5,
			"suspension": 5,
			"fuel": 3
		}
	},
	"car_14": {
		"front_weight_ratio": 0.4,
		"rear_weight_ratio": 0.6,

		"id": "car_14",
		"display_name": "Super Sport Racing Superbike",
		"description": "Aerodynamic track motorcycle capable of blistering straight-line speed and precision mid-air tilts.",
		"scene_path": "res://scenes/vehicle/garage/car_14.tscn",
		"preview_path": "res://assets/vehicles/garage/car_14/car_14.png",
		"unlock_cost": 500,
		"mass": 200.0,
		"stat_ratings": {
			"power": 5,
			"grip": 4,
			"suspension": 3,
			"fuel": 3
		}
	},
	"car_15": {
		"front_weight_ratio": 0.4,
		"rear_weight_ratio": 0.6,

		"id": "car_15",
		"display_name": "Custom Chopper Beast",
		"description": "Custom stretched cruiser motorcycle with long front raked fork and roaring low-end torque.",
		"scene_path": "res://scenes/vehicle/garage/car_15.tscn",
		"preview_path": "res://assets/vehicles/garage/car_15/car_15.png",
		"unlock_cost": 400,
		"mass": 300.0,
		"stat_ratings": {
			"power": 4,
			"grip": 4,
			"suspension": 3,
			"fuel": 4
		}
	},
	"car_16": {
		"front_weight_ratio": 0.4,
		"rear_weight_ratio": 0.6,

		"id": "car_16",
		"display_name": "Off-Road Motocross Dirt Bike",
		"description": "Competition off-road dirt bike engineered for high-flying jumps and rapid backflips.",
		"scene_path": "res://scenes/vehicle/garage/car_16.tscn",
		"preview_path": "res://assets/vehicles/garage/car_16/car_16.png",
		"unlock_cost": 350,
		"mass": 200.0,
		"stat_ratings": {
			"power": 4,
			"grip": 5,
			"suspension": 4,
			"fuel": 4
		}
	},
	"car_17": {
		"front_weight_ratio": 0.4,
		"rear_weight_ratio": 0.6,

		"id": "car_17",
		"display_name": "Streetfighter Naked Bike",
		"description": "Raw performance street motorcycle with instant throttle response and nimble stance.",
		"scene_path": "res://scenes/vehicle/garage/car_17.tscn",
		"preview_path": "res://assets/vehicles/garage/car_17/car_17.png",
		"unlock_cost": 420,
		"mass": 200.0,
		"stat_ratings": {
			"power": 4,
			"grip": 4,
			"suspension": 3,
			"fuel": 4
		}
	},
	"car_18": {
		"front_weight_ratio": 0.55,
		"rear_weight_ratio": 0.45,

		"id": "car_18",
		"display_name": "Convertible Roadster Mini",
		"description": "Sleek open-top roadster with low center of gravity and excellent aerodynamic stability.",
		"scene_path": "res://scenes/vehicle/garage/car_18.tscn",
		"preview_path": "res://assets/vehicles/garage/car_18/car_18.png",
		"unlock_cost": 380,
		"mass": 1300.0,
		"stat_ratings": {
			"power": 4,
			"grip": 4,
			"suspension": 3,
			"fuel": 4
		}
	},
	"car_19": {
		"front_weight_ratio": 0.55,
		"rear_weight_ratio": 0.45,

		"id": "car_19",
		"display_name": "Off-Road Spiked Beast Buggy",
		"description": "Post-apocalyptic sand buggy outfitted with spiked treads and reinforced roll bar.",
		"scene_path": "res://scenes/vehicle/garage/car_19.tscn",
		"preview_path": "res://assets/vehicles/garage/car_19/car_19.png",
		"unlock_cost": 450,
		"mass": 1300.0,
		"stat_ratings": {
			"power": 4,
			"grip": 5,
			"suspension": 4,
			"fuel": 4
		}
	},
	"car_24": {
		"front_weight_ratio": 0.4,
		"rear_weight_ratio": 0.6,

		"id": "car_24",
		"display_name": "Highway Touring Cruiser",
		"description": "Full-dress touring cruiser motorcycle with deep saddle comfort and massive highway range.",
		"scene_path": "res://scenes/vehicle/garage/car_24.tscn",
		"preview_path": "res://assets/vehicles/garage/car_24/car_24.png",
		"unlock_cost": 450,
		"mass": 380.0,
		"stat_ratings": {
			"power": 4,
			"grip": 4,
			"suspension": 4,
			"fuel": 5
		}
	},
	"car_25": {
		"front_weight_ratio": 0.4,
		"rear_weight_ratio": 0.6,

		"id": "car_25",
		"display_name": "Urban City Commuter Bike",
		"description": "Practical modern city motorcycle with smooth acceleration and great fuel efficiency.",
		"scene_path": "res://scenes/vehicle/garage/car_25.tscn",
		"preview_path": "res://assets/vehicles/garage/car_25/car_25.png",
		"unlock_cost": 280,
		"mass": 300.0,
		"stat_ratings": {
			"power": 3,
			"grip": 4,
			"suspension": 3,
			"fuel": 5
		}
	}
}

## Returns an array of all vehicle metadata dictionaries (starters + garage vehicles)
static func get_all_vehicles() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for key in ORDERED_IDS:
		if VEHICLES.has(key):
			result.append(VEHICLES[key])
	return result

## Returns an array of starter vehicles for the initial quick carousel
static func get_starter_vehicles() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for key in STARTER_IDS:
		if VEHICLES.has(key):
			result.append(VEHICLES[key])
	return result

## Returns an array of the 25 collected garage vehicles
static func get_garage_vehicles() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for key in GARAGE_COLLECTED_IDS:
		if VEHICLES.has(key):
			result.append(VEHICLES[key])
	return result

## Returns vehicle metadata for a given ID, or empty dictionary if invalid
static func get_vehicle(id: String) -> Dictionary:
	return VEHICLES.get(id, {})

## Returns all registered vehicle IDs
static func get_vehicle_ids() -> Array[String]:
	return ORDERED_IDS.duplicate()

## Returns true if the vehicle ID is recognized
static func has_vehicle(id: String) -> bool:
	return VEHICLES.has(id)

## Instantiates and returns a VehicleController instance for the specified vehicle ID
static func instantiate_vehicle(id: String) -> VehicleController:
	var entry: Dictionary = get_vehicle(id)
	if entry.is_empty():
		push_error("VehicleRegistry: Unknown vehicle ID '%s'" % id)
		return null
	
	var packed: PackedScene = load(entry["scene_path"]) as PackedScene
	if not packed:
		push_error("VehicleRegistry: Failed to load scene '%s'" % entry["scene_path"])
		return null
		
	var controller: VehicleController = packed.instantiate() as VehicleController
	if controller:
		controller.vehicle_id = id
		controller._apply_vehicle_config()
	return controller

## Calculates coin cost required to upgrade a stat to the next level
static func get_upgrade_cost(current_level: int) -> int:
	match current_level:
		1: return 50
		2: return 120
		3: return 250
		4: return 500
		_: return 0 # Max level reached

## Returns the shared truck configuration for Bigfoot Heavy Monster Truck (car_08)
static func get_bigfoot_config() -> Dictionary:
	return BIGFOOT_CONFIG.duplicate(true)

## Returns unified config dictionary for any vehicle or bike ID

## Returns default suspension parameters for a given vehicle ID
static func get_default_suspension_config(id: String) -> Dictionary:
	if id == "car_08":
		return SUSPENSION_CONFIG_BIGFOOT.duplicate()
	if id in ["car_14", "car_16", "car_17"]:
		return SUSPENSION_CONFIG_SPORT_BIKE.duplicate()
	if id in ["car_15", "car_24", "car_25"]:
		return SUSPENSION_CONFIG_CRUISER_BIKE.duplicate()
	if id in ["blue_flame_truck", "trophy_truck", "car_04", "car_06", "car_07", "car_10", "car_11"]:
		return SUSPENSION_CONFIG_TRUCK.duplicate()
	return SUSPENSION_CONFIG_CAR.duplicate()

static func get_vehicle_config(id: String) -> Dictionary:
	if VEHICLE_CONFIGS.has(id):
		return VEHICLE_CONFIGS[id].duplicate(true)
	return {}

## Returns the base boost force of a vehicle before multipliers
static func get_vehicle_base_boost(id: String) -> float:
	if id == "car_08":
		return BIGFOOT_BOOST_FORCE
	if VEHICLE_CONFIGS.has(id):
		return float(VEHICLE_CONFIGS[id].get("base_boost_force", DEFAULT_BASE_BOOST_FORCE))
	return DEFAULT_BASE_BOOST_FORCE

## Returns boost force directly from the vehicle config
static func get_vehicle_boost(id: String) -> float:
	return get_vehicle_base_boost(id) * GLOBAL_BOOST_MULTIPLIER

## Returns final boost force from vehicle (no character bonus)
static func get_final_boost(vehicle_id: String, _ignored: String = "") -> float:
	return get_vehicle_boost(vehicle_id)

## Returns boost power multiplier for a vehicle (Bigfoot is 1.15x, normal vehicles are 1.0x)
static func get_boost_power_multiplier(vehicle_id: String) -> float:
	if vehicle_id == "car_08":
		return BIGFOOT_BOOST_BONUS
	if VEHICLE_CONFIGS.has(vehicle_id):
		return float(VEHICLE_CONFIGS[vehicle_id].get("boost_power_multiplier", BOOST_POWER_MULTIPLIER))
	return BOOST_POWER_MULTIPLIER

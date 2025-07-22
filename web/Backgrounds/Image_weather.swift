//
//  Image_weather.swift
//  web
//
//  Created by Anton on 20.02.2025.
//

import SwiftUI

//картинка по индексу погоды -
func image_weather(index: Int, night: Bool) -> String {
    if night {
        switch index {
        case 0:
            return "moon"
        case 1:
            return "moon"
        case 2:
            return "cloud.moon"
        case 3:
            return "cloud"
        case 45, 48: //туман
            return "cloud.fog"
        case 51, 53, 55, 56, 57: //морось
            return "cloud.drizzle"
        case 61, 63, 65, 66, 67: //дождь
            return "cloud.rain"
        case 71, 73, 75, 77: //снег
            return "snowflake"
        case 95, 96, 99: //гроза
            return "bolt"
        default:
            return "moon"
        }
    }
    
    switch index {
    case 0:
        return "sun.max"
    case 1:
        return "sun.min"
    case 2:
        return "cloud.sun"
    case 3:
        return "cloud"
    case 45, 48: //туман
        return "cloud.fog"
    case 51, 53, 55, 56, 57: //морось
        return "cloud.drizzle"
    case 61, 63, 65, 66, 67: //дождь
        return "cloud.rain"
    case 71, 73, 75, 77: //снег
        return "snowflake"
    case 95, 96, 99: //гроза
        return "bolt"
    default:
        return "sun.max"
    }
}

func weather_description(index: Int) -> String {
    switch index {
    case 0:
        return "Clear sky"
    case 1:
        return "Mainly clear"
    case 2:
        return "Partly cloudy"
    case 3:
        return "Overcast"
    case 45, 48: //туман
        return "Fog"
    case 51, 53, 55, 56, 57: //морось
        return "Drizzle"
    case 61, 63, 65, 66, 67: //дождь
        return "Rain"
    case 71, 73, 75, 77: //снег
        return "Snow"
    case 95, 96, 99: //гроза
        return "Bolt"
    default:
        return "Clear sky"
    }
}

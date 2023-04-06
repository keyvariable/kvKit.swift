//===----------------------------------------------------------------------===//
//
//  Copyright (c) 2021 Svyatoslav Popov (info@keyvar.com).
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
//  the License. You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
//  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
//  specific language governing permissions and limitations under the License.
//
//  SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
//
//  KvDateKit.swift
//  KvKit
//
//  Created by Svyatoslav Popov on 19.02.2018.
//

import Foundation



public class KvDateKit {

    public static let gmtCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()


    public static let moscowCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ru_RU")
        calendar.timeZone = TimeZone(identifier: "Europe/Moscow")!
        return calendar
    }()


    public static let utcCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        return calendar
    }()



    @available(iOS 10.0, macOS 10.12, *)
    public static func distance<T: BinaryFloatingPoint>(in unit: Calendar.Component,
                                                        scale: Calendar.Component,
                                                        from startDate: Date,
                                                        till endDate: Date,
                                                        _ calendar: Calendar) -> T?
    {
        guard let startDateUnitInterval = calendar.dateInterval(of: unit, for: startDate),
            let startDateScaleInterval = calendar.dateInterval(of: scale, for: startDate),
            let endDateUnitInterval = calendar.dateInterval(of: unit, for: endDate),
            let endDateScaleInterval = calendar.dateInterval(of: scale, for: endDate) else {
                return nil
        }

        let startUnit = T(calendar.component(unit, from: startDateUnitInterval.start))
        let endUnit = T(calendar.component(unit, from: endDateUnitInterval.end))

        return endUnit
            - startUnit
            - T(startDateScaleInterval.start.timeIntervalSince(startDateUnitInterval.start) / startDateUnitInterval.duration)
            - T(endDateUnitInterval.end.timeIntervalSince(endDateScaleInterval.end) / endDateUnitInterval.duration)
    }

}



// MARK: Constants

extension KvDateKit {

    // MARK: Weekday

    public enum Weekday : Int {
        case monday = 2
        case tuesday = 3
        case wednesday = 4
        case thursday = 5
        case friday = 6
        case saturday = 7
        case sunday = 1
    }

}

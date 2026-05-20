//
//  IndicatorBundle.swift
//  Indicator
//
//  Created by Sendi Setiawan on 19/05/26.
//

import WidgetKit
import SwiftUI

@main
struct IndicatorBundle: WidgetBundle {
    var body: some Widget {
        Indicator()
        IndicatorControl()
        IndicatorLiveActivity()
    }
}

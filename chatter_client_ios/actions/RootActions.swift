//
//  RootActions.swift
//  chatter_client_ios
//
//  Actions for Root reducer
//
//  Created by user on 19.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import Foundation
import ReSwift

/**
 * Action used to change current application screen
 */
struct ChangeActivityAction: Action {
    /// Screen to move to
    let activity: AppScreens
}

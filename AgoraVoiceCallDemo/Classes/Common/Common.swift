//
//  Common.swift
//  AgoraVoiceCallDemo
//
//  Created by Nirzar Gandhi on 26/02/25.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift

// MARK: - UI / Device Related Functions
func GetStoryBoard(identifier: String, storyBoardName: String) -> UIViewController {
    return UIStoryboard(name: storyBoardName, bundle: nil).instantiateViewController(withIdentifier: identifier)
}

func getBottomSafeAreaHeight() -> CGFloat {
    return (UIDevice.current.hasNotch == true) ? (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0) : 0
}


// MARK: - Call Duration
func callDurationFormater(time: Double) -> String {
    
    let hours = Int(time) / 3600
    let minutes = Int(time) / 60 % 60
    let seconds = Int(time) % 60
    
    return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
}


// MARK: - Keyboard Appearance
func keyboardAppearance() {
    
    IQKeyboardManager.shared.enable = true
    IQKeyboardManager.shared.toolbarTintColor = UIColor.black
    IQKeyboardManager.shared.keyboardAppearance = UIKeyboardAppearance.default
}

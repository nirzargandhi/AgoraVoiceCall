//
//  Extensions.swift
//  AgoraVoiceCallDemo
//
//  Created by Nirzar Gandhi on 25/02/25.
//

import Foundation
import UIKit

// MARK: - UIViewController
extension UIViewController {
    
    // Add Navigation Bottom Shadow
    func hideNavigationBottomShadow() {
        self.navigationController?.navigationBar.layer.masksToBounds = true
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.clear.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.0
    }
    
    // Alert Controller
    func showAlertWithDismiss(title: String?, message :String?, cancelButtonTitle: String = "Okay", handler: @escaping () -> Void) {
        
        let title = title
        let message = message
        let cancelButtonTitle = cancelButtonTitle
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Create the action.
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .default) { action in
            handler()
        }
        
        // Add the action.
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}


// MARK: - UIButton
extension UIButton {
    
    func startAnimatingPressActions() {
        addTarget(self, action: #selector(animateDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(animateUp), for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside])
    }
    
    @objc private func animateDown(sender: UIButton) {
        animate(sender, transform: CGAffineTransform.identity.scaledBy(x: 0.94, y: 0.94))
        //animate(sender, transform: CGAffineTransform.identity.scaledBy(x: 1.06, y: 1.06))
    }
    
    @objc private func animateUp(sender: UIButton) {
        animate(sender, transform: .identity)
    }
    
    private func animate(_ button: UIButton, transform: CGAffineTransform) {
        
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 3,
                       options: [.curveEaseInOut],
                       animations: {
            button.transform = transform
        }, completion: nil)
    }
}


// MARK: - UIDevice
extension UIDevice {
    
    var hasNotch: Bool {
        let bottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}

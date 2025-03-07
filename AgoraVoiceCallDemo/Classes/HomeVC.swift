//
//  HomeVC.swift
//  AgoraVoiceCallDemo
//
//  Created by Nirzar Gandhi on 25/02/25.
//

import UIKit
import CallKit
import AudioToolbox

class HomeVC: BaseVC {
    
    // MARK: - IBOutlets
    @IBOutlet weak var channelIdTF: UITextField!
    @IBOutlet weak var startCallBtn: UIButton!
    
    @IBOutlet weak var startCallBtnBottom: NSLayoutConstraint!
    
    
    // MARK: - Properties
    fileprivate lazy var soundID: SystemSoundID = 0
    fileprivate lazy var bottomConstant: CGFloat = 20
    
    
    // MARK: -
    // MARK: - View init Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Home"
        
        self.setControlsProperty()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NC.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NC.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NC.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NC.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    fileprivate func setControlsProperty() {
        
        self.view.backgroundColor = .clear
        self.view.isOpaque = false
        
        // Channel Id TextField
        self.channelIdTF.backgroundColor = .white
        self.channelIdTF.textColor = .black
        self.channelIdTF.tintColor = .black
        self.channelIdTF.font = UIFont.systemFont(ofSize: 14)
        self.channelIdTF.keyboardType = .default
        self.channelIdTF.autocorrectionType = .no
        self.channelIdTF.attributedPlaceholder = NSAttributedString(string: "Enter channel id", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        self.channelIdTF.text = ""
        
        // Start Call Butttons
        self.startCallBtn.backgroundColor = .black
        self.startCallBtn.titleLabel?.backgroundColor = .black
        self.startCallBtn.setTitleColor(.white, for: .normal)
        self.startCallBtn.setTitle("Start Call", for: .normal)
        
        self.startCallBtnBottom.constant = UIDevice.current.hasNotch ? getBottomSafeAreaHeight() : self.bottomConstant
    }
}


// MARK: - Call Back
extension HomeVC {
    
    @objc fileprivate func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            if SCREENHEIGHT <= 667 {
                return
            }
            
            self.startCallBtnBottom.constant = keyboardSize.height - getBottomSafeAreaHeight() + self.bottomConstant + (UIDevice.current.hasNotch ? 20 : 0)
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @objc fileprivate func keyboardWillHide(_ notification: Notification) {
        
        if SCREENHEIGHT <= 667 {
            return
        }
        
        self.startCallBtnBottom.constant = UIDevice.current.hasNotch ? getBottomSafeAreaHeight() : self.bottomConstant
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}


// MARK: - Button Touch & Action
extension HomeVC {
    
    @IBAction func startCallBtnTouch(_ sender: UIButton) {
        
        self.channelIdTF.resignFirstResponder()
        
        guard let channelId = self.channelIdTF.text, channelId.count > 0 else {
            self.showAlertWithDismiss(title: "", message: "Please enter channel id") { }
            return
        }
        
        let voiceCallVC = GetStoryBoard(identifier: "VoiceCallVC", storyBoardName: Constants.Storyboard.Main) as! VoiceCallVC
        voiceCallVC.channelId = channelId
        voiceCallVC.isCalling = false
        self.navigationController?.pushViewController(voiceCallVC, animated: true)
    }
}

//
//  VoiceCallVC.swift
//  AgoraVoiceCallDemo
//
//  Created by Nirzar Gandhi on 25/02/25.
//

import UIKit
import AudioToolbox
import AgoraRtcKit

class VoiceCallVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var callingContainer: UIView!
    @IBOutlet weak var callingPersonNameLabel: UILabel!
    @IBOutlet weak var callingBtnStackView: UIStackView!
    @IBOutlet weak var acceptCallBtn: UIButton!
    @IBOutlet weak var endCallBtn: UIButton!
    
    @IBOutlet weak var callConnectedContainer: UIView!
    @IBOutlet weak var callDurationLabel: UILabel!
    @IBOutlet weak var callConnectedBtnStackView: UIStackView!
    @IBOutlet weak var endConnectedCallBtn: UIButton!
    
    
    // MARK: - Properties
    fileprivate let appIdStr = "71658792fb34415ab49ec47840e3d580"
    
    fileprivate var agoraRTCKit : AgoraRtcEngineKit!
    
    lazy var channelId = ""
    lazy var uuid = UUID()
    lazy var isCalling = false
    
    fileprivate lazy var callDuration = 0.0
    fileprivate weak var timer: Timer?
    
    
    // MARK: -
    // MARK: - View init Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Voice Call"
        
        self.setControlsProperty()
        
        self.initializeAgoraEngine()
        
        if self.isCalling {
            CallKitManager.shared.startCall(receiverId: "Dummy", uuid: self.uuid)
        } else {
            CallKitManager.shared.reportIncomingCall(uuid: self.uuid, callerName: "Nirzar")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.joinChannel()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NC.addObserver(self, selector: #selector(self.leaveChannel), name: NSNotification.Name(rawValue: Constants.NotifId.LEAVE_CHANNEL), object: nil)
    }
    
    fileprivate func setControlsProperty() {
        
        self.view.backgroundColor = .clear
        self.view.isOpaque = false
        
        // Calling Container
        self.callingContainer.backgroundColor = .white
        
        // Calling Person Name Label
        self.callingPersonNameLabel.backgroundColor = .clear
        self.callingPersonNameLabel.textColor = .black
        self.callingPersonNameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        self.callingPersonNameLabel.numberOfLines = 1
        self.callingPersonNameLabel.lineBreakMode = .byTruncatingTail
        self.callingPersonNameLabel.textAlignment = .center
        self.callingPersonNameLabel.text = ""
        
        // Calling Button StackView
        self.callingBtnStackView.backgroundColor = .clear
        self.callingBtnStackView.axis = .horizontal
        self.callingBtnStackView.alignment = .center
        self.callingBtnStackView.distribution = .fillEqually
        self.callingBtnStackView.spacing = SCREENWIDTH - 120 - 40
        
        // Accept Call Buttton
        self.acceptCallBtn.backgroundColor = .clear
        self.acceptCallBtn.setImage(UIImage(named: "acceptCallIcon"), for: .normal)
        self.acceptCallBtn.showsTouchWhenHighlighted = false
        self.acceptCallBtn.adjustsImageWhenHighlighted = false
        self.acceptCallBtn.adjustsImageWhenDisabled = false
        self.acceptCallBtn.startAnimatingPressActions()
        self.acceptCallBtn.isHidden = true
        
        // End Call Buttton
        self.endCallBtn.backgroundColor = .clear
        self.endCallBtn.setImage(UIImage(named: "endCallIcon"), for: .normal)
        self.endCallBtn.showsTouchWhenHighlighted = false
        self.endCallBtn.adjustsImageWhenHighlighted = false
        self.endCallBtn.adjustsImageWhenDisabled = false
        self.endCallBtn.startAnimatingPressActions()
        
        // Call Connected Container
        self.callConnectedContainer.backgroundColor = .white
        
        // Call Duration Label
        self.callDurationLabel.backgroundColor = .clear
        self.callDurationLabel.textColor = .black
        self.callDurationLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        self.callDurationLabel.numberOfLines = 1
        self.callDurationLabel.lineBreakMode = .byTruncatingTail
        self.callDurationLabel.textAlignment = .center
        self.callDurationLabel.text = ""
        
        // Call Connected Button StackView
        self.callConnectedBtnStackView.backgroundColor = .clear
        self.callConnectedBtnStackView.axis = .horizontal
        self.callConnectedBtnStackView.alignment = .center
        self.callConnectedBtnStackView.distribution = .fillEqually
        self.callConnectedBtnStackView.spacing = SCREENWIDTH - 120 - 40
        
        // End Connected Call Buttton
        self.endConnectedCallBtn.backgroundColor = .clear
        self.endConnectedCallBtn.setImage(UIImage(named: "endCallIcon"), for: .normal)
        self.endConnectedCallBtn.showsTouchWhenHighlighted = false
        self.endConnectedCallBtn.adjustsImageWhenHighlighted = false
        self.endConnectedCallBtn.adjustsImageWhenDisabled = false
        self.endConnectedCallBtn.startAnimatingPressActions()
    }
}


// MARK: - Call Back
extension VoiceCallVC {
    
    fileprivate func initializeAgoraEngine() {
        
        self.agoraRTCKit = AgoraRtcEngineKit.sharedEngine(withAppId: self.appIdStr, delegate: self)
        self.agoraRTCKit.setAudioProfile(.speechStandard)
        self.agoraRTCKit.setDefaultAudioRouteToSpeakerphone(false)
        self.agoraRTCKit.setEnableSpeakerphone(false)
        self.agoraRTCKit.enable(inEarMonitoring: true)
        self.agoraRTCKit.setParameters("{\"che.audio.noiseSuppression\":true}")
    }
    
    fileprivate func joinChannel() {
        
        let option = AgoraRtcChannelMediaOptions()
        option.clientRoleType = .broadcaster
        option.channelProfile = .communication
        
        option.publishMicrophoneTrack = true
        option.autoSubscribeAudio = true
        
        self.agoraRTCKit.joinChannel(byToken: "", channelId: self.channelId, uid: 0, mediaOptions: option, joinSuccess: { (channel, uid, elapsed) in
            self.agoraRTCKit.muteLocalAudioStream(false)
        })
    }
    
    @objc fileprivate func leaveChannel() {
        
        if self.agoraRTCKit != nil {
            self.agoraRTCKit.leaveChannel(nil)
        }
        
        self.agoraRTCKit = nil
        
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func startCallTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCallTimer), userInfo: nil, repeats: true)
    }
    
    @objc fileprivate func updateCallTimer() {
        
        self.callDuration += 1.0
        
        self.callDurationLabel.text = callDurationFormater(time: self.callDuration)
    }
    
    fileprivate func endCallTimer() {
        
        self.timer?.invalidate()
        self.timer = nil
    }
}


//MARK: - AgoraRtcEngineDelegate Extensions
extension VoiceCallVC : AgoraRtcEngineDelegate {
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
        print("warning: \(warningCode)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        
        print("❌ Failed to join channel: \(errorCode.rawValue)")
        
        switch errorCode {
            
        case .invalidAppId:
            print("🚨 Error 101: Invalid App ID. Please check your Agora App ID.")
            
        case .invalidToken:
            print("🚨 Error 110: Invalid Token. Generate a new token.")
            
        case .tokenExpired:
            print("🚨 Error 109: Token Expired. Regenerate and use a fresh token.")
            
        default:
            print("🚨 Unknown error: \(errorCode.rawValue)")
        }
        
        CallKitManager.shared.reportCallEnded(uuid: self.uuid, reason: .remoteEnded)
        
        self.leaveChannel()
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        print("Joined \(channel) with uid \(uid) elapsed \(elapsed)ms")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid:UInt, size:CGSize, elapsed:Int) {
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        
        CallKitManager.shared.reportCallConnected(uuid: self.uuid)
        
        self.startCallTimer()
        
        self.callingContainer.isHidden = true
        self.callConnectedContainer.isHidden = false
        
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid:UInt, reason:AgoraUserOfflineReason) {
        
        if reason == .quit || reason == .dropped {
            CallKitManager.shared.reportCallEnded(uuid: self.uuid, reason: .remoteEnded)
        } else {
            CallKitManager.shared.endCall(uuid: self.uuid)
        }
        
        self.leaveChannel()
    }
}


// MARK: - Button Touch & Action
extension VoiceCallVC {
    
    @IBAction func acceptCallBtnTouch(_ sender: Any) {
        
        CallKitManager.shared.answerCall(uuid: self.uuid)
        
        self.joinChannel()
    }
    
    @IBAction func endCallBtnTouch(_ sender: Any) {
        
        CallKitManager.shared.endCall(uuid: self.uuid)
        
        self.leaveChannel()
    }
}
